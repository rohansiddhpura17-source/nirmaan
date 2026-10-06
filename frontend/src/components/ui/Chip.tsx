import React from 'react';
import { cn } from '@/lib/utils';

export interface ChipProps {
  label: string;
  isSelected?: boolean;
  onSelect?: () => void;
  icon?: React.ReactNode;
  count?: number | string;
  variant?: 'default' | 'filter' | 'role';
  className?: string;
}

export const Chip: React.FC<ChipProps> = ({
  label,
  isSelected = false,
  onSelect,
  icon,
  count,
  variant = 'default',
  className,
}) => {
  return (
    <button
      type="button"
      onClick={onSelect}
      className={cn(
        'inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold transition-all select-none',
        isSelected
          ? 'bg-[#0284C7] text-white shadow-sm ring-2 ring-[#0284C7]/20'
          : 'bg-slate-100 text-slate-700 hover:bg-slate-200 border border-transparent',
        variant === 'filter' && !isSelected && 'bg-white border-slate-200 text-slate-600 hover:bg-slate-50',
        variant === 'role' && isSelected && 'bg-[#0F172A] text-white ring-[#0F172A]/20',
        className
      )}
    >
      {icon && <span className="w-3.5 h-3.5 flex items-center justify-center">{icon}</span>}
      <span>{label}</span>
      {count !== undefined && (
        <span
          className={cn(
            'ml-1 px-1.5 py-0.2 rounded-full text-[10px] font-bold',
            isSelected ? 'bg-white/20 text-white' : 'bg-slate-200 text-slate-700'
          )}
        >
          {count}
        </span>
      )}
    </button>
  );
};
