import React from 'react';
import { Card } from './Card';
import { cn } from '@/lib/utils';

export interface BarChartItem {
  label: string;
  value: number;
  displayValue?: string;
  color?: string;
}

export interface ChartProps {
  title: string;
  subtitle?: string;
  data: BarChartItem[];
  maxValue?: number;
  type?: 'bar' | 'progress';
  className?: string;
  height?: number;
}

export const Chart: React.FC<ChartProps> = ({
  title,
  subtitle,
  data,
  maxValue,
  type = 'bar',
  className,
}) => {
  const computedMax = maxValue || Math.max(...data.map((d) => d.value), 1);

  return (
    <Card className={cn('p-5', className)}>
      <div className="mb-4">
        <h3 className="font-semibold text-slate-900 text-sm">{title}</h3>
        {subtitle && <p className="text-xs text-slate-500 mt-0.5">{subtitle}</p>}
      </div>

      {type === 'bar' ? (
        <div className="flex items-end gap-3 h-44 pt-4 px-2 border-b border-slate-100">
          {data.map((item, idx) => {
            const heightPercent = Math.min(100, Math.max(8, (item.value / computedMax) * 100));
            return (
              <div key={idx} className="flex-1 flex flex-col items-center gap-2 group h-full justify-end">
                <div className="text-[10px] font-bold text-slate-400 opacity-0 group-hover:opacity-100 transition-opacity">
                  {item.displayValue || item.value}
                </div>
                <div className="w-full max-w-[36px] bg-slate-100 rounded-t-lg relative flex items-end h-full overflow-hidden">
                  <div
                    style={{ height: `${heightPercent}%` }}
                    className={cn(
                      'w-full rounded-t-lg transition-all duration-500',
                      item.color || 'bg-[#0284C7] group-hover:bg-[#0369A1]'
                    )}
                  />
                </div>
                <span className="text-[11px] font-medium text-slate-500 truncate max-w-full">
                  {item.label}
                </span>
              </div>
            );
          })}
        </div>
      ) : (
        <div className="space-y-3.5">
          {data.map((item, idx) => {
            const widthPercent = Math.min(100, (item.value / computedMax) * 100);
            return (
              <div key={idx} className="space-y-1.5">
                <div className="flex items-center justify-between text-xs">
                  <span className="font-medium text-slate-700">{item.label}</span>
                  <span className="font-semibold text-slate-900">
                    {item.displayValue || item.value}
                  </span>
                </div>
                <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
                  <div
                    style={{ width: `${widthPercent}%` }}
                    className={cn(
                      'h-full rounded-full transition-all duration-500',
                      item.color || 'bg-[#0284C7]'
                    )}
                  />
                </div>
              </div>
            );
          })}
        </div>
      )}
    </Card>
  );
};
