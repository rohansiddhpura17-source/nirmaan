import React from 'react';
import { Sparkles, Loader2 } from 'lucide-react';

export const SessionLoadingState: React.FC = () => {
  return (
    <div className="min-h-screen bg-[#0F172A] flex flex-col items-center justify-center p-6 text-white relative overflow-hidden">
      {/* Background ambient glow */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 w-80 h-80 bg-gradient-to-tr from-sky-600/20 to-indigo-600/20 blur-3xl pointer-events-none rounded-full" />

      <div className="flex flex-col items-center text-center z-10 space-y-5">
        <div className="relative">
          <div className="w-20 h-20 rounded-2xl bg-gradient-to-tr from-[#0284C7] to-indigo-600 flex items-center justify-center text-white shadow-2xl shadow-sky-500/30 text-4xl font-black">
            N
          </div>
          <div className="absolute -bottom-1 -right-1 bg-indigo-500 text-white p-1 rounded-full shadow-lg">
            <Sparkles className="w-3.5 h-3.5" />
          </div>
        </div>

        <div className="space-y-1">
          <h2 className="text-xl font-bold tracking-tight text-white">NIRMAAN</h2>
          <p className="text-xs text-slate-400 font-medium">Restoring secure session...</p>
        </div>

        <div className="flex items-center gap-2 text-xs text-sky-400 font-medium pt-2">
          <Loader2 className="w-4 h-4 animate-spin" />
          <span>Verifying credentials</span>
        </div>
      </div>
    </div>
  );
};
