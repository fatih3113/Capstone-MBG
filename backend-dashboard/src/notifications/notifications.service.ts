import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(private readonly prisma: PrismaService) {}

  async notifyMenuScheduled(menuId: string): Promise<{ sent: number }> {
    const menu = await this.prisma.mbgMenu.findUnique({
      where: { id: menuId },
      include: {
        school: true,
        items: { include: { food: true } },
      },
    });

    if (!menu) {
      this.logger.warn(`Menu ${menuId} tidak ditemukan, notifikasi dilewati`);
      return { sent: 0 };
    }

    const students = await this.prisma.user.findMany({
      where: {
        role: 'student',
        OR: [
          { schoolId: menu.schoolId },
          ...(menu.school.sppgId ? [{ sppgId: menu.school.sppgId }] : []),
        ],
      },
      select: { id: true },
    });

    if (students.length === 0) {
      this.logger.warn(
        `Tidak ada siswa untuk sekolah "${menu.school.name}". ` +
          `Pastikan schoolId/sppgId siswa terisi.`,
      );
      return { sent: 0 };
    }

    // Hindari notifikasi ganda jika jadwal yang sama dikirim ulang
    const already = await this.prisma.notification.findMany({
      where: {
        type: 'distribution',
        data: { path: ['menuId'], equals: menu.id },
      },
      select: { userId: true },
    });
    const alreadySet = new Set(already.map((a) => a.userId));
    const targets = students.filter((s) => !alreadySet.has(s.id));

    if (targets.length === 0) return { sent: 0 };

    const tanggal = new Date(menu.date).toLocaleDateString('id-ID', {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    });
    const itemList = menu.items.map((i) => ({
      name: i.food.name,
      portionGram: i.portionGram,
    }));
    const menuText = itemList.map((i) => i.name).join(', ');

    await this.prisma.notification.createMany({
      data: targets.map((s) => ({
        userId: s.id,
        title: '🍱 Ompreng MBG akan dibagikan',
        body: `${tanggal}\nMenu: ${menuText}`,
        type: 'distribution',
        data: {
          menuId: menu.id,
          schoolName: menu.school.name,
          date: new Date(menu.date).toISOString(),
          items: itemList,
        } as any,
      })),
    });

    this.logger.log(`Notifikasi distribusi terkirim ke ${targets.length} siswa (menu ${menu.id})`);
    return { sent: targets.length };
  }
}