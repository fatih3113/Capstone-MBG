import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AuthUser } from '../roles';

/** Ambil objek user dari JWT: @CurrentUser() user: AuthUser */
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): AuthUser => {
    return ctx.switchToHttp().getRequest().user;
  },
);
