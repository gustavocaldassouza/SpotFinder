import { Injectable, PipeTransform, BadRequestException } from '@nestjs/common';
import type { ZodSchema } from 'zod';

@Injectable()
export class ZodValidationPipe implements PipeTransform {
  constructor(private schema: ZodSchema) {}

  transform(value: unknown) {
    try {
      console.log('🔍 Validating request body:', JSON.stringify(value));
      const result = this.schema.parse(value);
      console.log('✅ Validation passed:', JSON.stringify(result));
      return result;
    } catch (error) {
      console.error('❌ Validation failed:', error);
      throw new BadRequestException({
        message: 'Validation failed',
        errors: error.errors || error.message,
      });
    }
  }
}
