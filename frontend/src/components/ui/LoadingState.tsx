import React from 'react';
import { LoadingSpinner } from './LoadingSpinner';
import { cn } from '@/lib/utils';

export interface LoadingStateProps {
  message?: string;
  className?: string;
  fullScreen?: boolean;
}

export const LoadingState: React.FC<LoadingStateProps> = ({
  message = 'Loading business data...',
  className,
  fullScreen = false,
}) => {
  const content = (
    <div className={cn('flex flex-col items-center justify-center p-8 gap-3', className)}>
      <LoadingSpinner size="lg" />
      <p className="text-sm font-medium text-slate-500 animate-pulse">{message}</p>
    </div>
  );

  if (fullScreen) {
    return (
      <div className="fixed inset-0 bg-white/80 backdrop-blur-sm z-50 flex items-center justify-center">
        {content}
      </div>
    );
  }

  return content;
};
