import React from 'react';
import { Card } from './Card';
import { cn } from '@/lib/utils';
import { TrendingUp, TrendingDown } from 'lucide-react';

export interface MetricCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  change?: string;
  isPositive?: boolean;
  icon?: React.ReactNode;
  iconBgColor?: string;
  trendText?: string;
  variant?: 'default' | 'navy' | 'ai' | 'amber';
  className?: string;
}

export const MetricCard: React.FC<MetricCardProps> = ({
  title,
  value,
  subtitle,
  change,
  isPositive = true,
  icon,
  iconBgColor,
  trendText,
  variant = 'default',
  className,
}) => {
  if (variant === 'navy') {
    return (
      <Card className={cn('bg-[#0F172A] text-white border-slate-800 p-5 shadow-lg', className)}>
        <div className="flex items-center justify-between">
          <span className="text-xs font-medium text-slate-400 uppercase tracking-wider">{title}</span>
          {icon && (
            <div className="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center text-[#38BDF8]">
              {icon}
            </div>
          )}
        </div>
        <div className="mt-3 text-2xl font-bold tracking-tight text-white">{value}</div>
        {subtitle && <p className="mt-1 text-xs text-slate-400">{subtitle}</p>}
      </Card>
    );
  }

  if (variant === 'ai') {
    return (
      <Card className={cn('border-indigo-100 bg-gradient-to-br from-indigo-50/60 to-white p-5 shadow-ai-card', className)}>
        <div className="flex items-center justify-between">
          <span className="text-xs font-semibold text-indigo-900 uppercase tracking-wider">{title}</span>
          {icon && (
            <div className="w-10 h-10 rounded-xl bg-indigo-100 flex items-center justify-center text-indigo-600">
              {icon}
            </div>
          )}
        </div>
        <div className="mt-3 text-2xl font-bold tracking-tight text-slate-900">{value}</div>
        {subtitle && <p className="mt-1 text-xs text-indigo-700/80">{subtitle}</p>}
      </Card>
    );
  }

  return (
    <Card className={cn('p-5 hover:shadow-card-hover transition-shadow', className)}>
      <div className="flex items-center justify-between">
        <span className="text-xs font-medium text-slate-500 uppercase tracking-wider">{title}</span>
        {icon && (
          <div
            className={cn(
              'w-10 h-10 rounded-xl flex items-center justify-center',
              iconBgColor || 'bg-sky-50 text-[#0284C7]'
            )}
          >
            {icon}
          </div>
        )}
      </div>

      <div className="mt-3 flex items-baseline gap-2">
        <span className="text-2xl font-bold tracking-tight text-slate-900">{value}</span>
        {change && (
          <span
            className={cn(
              'inline-flex items-center text-xs font-semibold px-1.5 py-0.5 rounded',
              isPositive
                ? 'bg-emerald-50 text-emerald-700'
                : 'bg-rose-50 text-rose-700'
            )}
          >
            {isPositive ? (
              <TrendingUp className="w-3 h-3 mr-0.5 inline" />
            ) : (
              <TrendingDown className="w-3 h-3 mr-0.5 inline" />
            )}
            {change}
          </span>
        )}
      </div>

      {(subtitle || trendText) && (
        <p className="mt-1.5 text-xs text-slate-500 font-medium">
          {subtitle || trendText}
        </p>
      )}
    </Card>
  );
};
