import React from 'react';
import { Outlet } from 'react-router-dom';

export const AuthLayout: React.FC = () => {
  return (
    <div className="min-h-screen bg-slate-900 flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
      {/* Background ambient accents */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-7xl h-96 bg-gradient-to-b from-sky-500/10 via-indigo-500/5 to-transparent blur-3xl pointer-events-none" />

      <div className="sm:mx-auto sm:w-full sm:max-w-md relative z-10 text-center">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-gradient-to-tr from-sky-500 to-indigo-600 text-white shadow-xl shadow-sky-500/20 mb-4 font-black text-2xl tracking-wider">
          N
        </div>
        <h1 className="text-3xl font-extrabold text-white tracking-tight">NIRMAAN</h1>
        <p className="mt-1 text-sm text-slate-400">AI-Powered Business OS for Local Businesses</p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md relative z-10 px-4 sm:px-0">
        <div className="bg-white py-8 px-6 sm:px-10 shadow-2xl rounded-2xl border border-slate-200">
          <Outlet />
        </div>
      </div>

      <div className="mt-8 text-center text-xs text-slate-500">
        <p>© 2026 NIRMAAN Operating System. All rights reserved.</p>
      </div>
    </div>
  );
};
