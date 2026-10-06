import React from 'react';
import { cn } from '@/lib/utils';

export interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'navy' | 'ai' | 'flat';
  padded?: boolean;
}

export const Card: React.FC<CardProps> = ({
  className,
  variant = 'default',
  padded = true,
  children,
  ...props
}) => {
  const variants = {
    default: 'bg-white border border-slate-200/80 shadow-sm text-slate-800',
    navy: 'bg-[#0F172A] border border-slate-800 text-white shadow-md',
    ai: 'relative bg-white border border-indigo-200/90 shadow-md ring-1 ring-indigo-500/10 before:absolute before:inset-0 before:rounded-2xl before:bg-gradient-to-r before:from-indigo-500/5 before:via-sky-500/5 before:to-transparent before:pointer-events-none',
    flat: 'bg-slate-50 border border-slate-200 text-slate-800',
  };

  return (
    <div
      className={cn(
        'rounded-2xl transition-all duration-200 overflow-hidden',
        variants[variant],
        padded && 'p-5 md:p-6',
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
};
