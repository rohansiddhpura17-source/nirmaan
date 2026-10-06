import { describe, it, expect } from 'vitest';
import { formatCurrency, cn } from '@/lib/utils';
import { getStockStatus } from '@/models/product';

describe('Nirmaan Frontend Foundation Unit Tests', () => {
  it('formats currency correctly with Indian Rupee symbol', () => {
    const formatted = formatCurrency(28450);
    expect(formatted).toContain('28,450');
    expect(formatted).toContain('₹');
  });

  it('determines stock status accurately according to thresholds', () => {
    expect(getStockStatus(0, 10)).toBe('OUT_OF_STOCK');
    expect(getStockStatus(5, 10)).toBe('LOW_STOCK');
    expect(getStockStatus(10, 10)).toBe('LOW_STOCK');
    expect(getStockStatus(11, 10)).toBe('IN_STOCK');
  });

  it('merges Tailwind classnames reliably', () => {
    const className = cn('p-4 text-sm', false && 'hidden', 'text-base');
    expect(className).toContain('p-4');
    expect(className).toContain('text-base');
    expect(className).not.toContain('text-sm');
  });
});
