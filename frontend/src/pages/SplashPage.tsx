import React, { useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { ArrowRight, Sparkles, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { useAuth } from '@/context/AuthContext';

export const SplashPage: React.FC = () => {
  const navigate = useNavigate();
  const { isAuthenticated, isLoading, user } = useAuth();

  const handleLaunch = () => {
    if (!isAuthenticated) {
      navigate('/login');
    } else if (user && !user.setupComplete) {
      navigate('/business-setup');
    } else {
      navigate('/dashboard');
    }
  };

  useEffect(() => {
    if (isLoading) return;

    // Optional gentle transition timer for smooth splash onboarding
    const timer = setTimeout(() => {
      if (isAuthenticated) {
        if (user && !user.setupComplete) {
          navigate('/business-setup');
        } else {
          navigate('/dashboard');
        }
      }
    }, 2500);

    return () => clearTimeout(timer);
  }, [isAuthenticated, isLoading, user, navigate]);

  return (
    <div className="min-h-screen bg-[#0F172A] flex flex-col items-center justify-between p-6 sm:p-12 text-white relative overflow-hidden">
      {/* Background ambient lighting */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-96 h-96 bg-gradient-to-tr from-sky-600/20 to-indigo-600/20 blur-3xl pointer-events-none rounded-full" />

      <div className="w-full max-w-sm flex items-center justify-between z-10">
        <span className="text-xs font-semibold text-sky-400 tracking-widest uppercase">
          Nirmaan OS
        </span>
        <span className="text-xs font-mono text-slate-400">v1.0.0</span>
      </div>

      <div className="flex flex-col items-center text-center z-10 max-w-md my-auto space-y-6">
        <div className="relative">
          <div className="w-24 h-24 rounded-3xl bg-gradient-to-tr from-[#0284C7] to-indigo-600 flex items-center justify-center text-white shadow-2xl shadow-sky-500/30 text-5xl font-black">
            N
          </div>
          <div className="absolute -bottom-2 -right-2 bg-indigo-500 text-white p-1.5 rounded-full shadow-lg">
            <Sparkles className="w-4 h-4" />
          </div>
        </div>

        <div className="space-y-2">
          <h1 className="text-4xl font-extrabold tracking-tight text-white">NIRMAAN</h1>
          <p className="text-base text-slate-300 font-medium">
            AI-Powered Business Operating System
          </p>
          <p className="text-xs text-slate-400 max-w-xs mx-auto">
            Smart inventory, instant POS billing, khata ledger, and predictive AI insights for local enterprises.
          </p>
        </div>

        {isLoading ? (
          <div className="flex items-center gap-2 text-xs text-sky-400 font-medium pt-2">
            <Loader2 className="w-4 h-4 animate-spin" />
            <span>Checking authentication session...</span>
          </div>
        ) : (
          <div className="flex flex-col sm:flex-row gap-3 w-full pt-4">
            <Button
              size="lg"
              variant="primary"
              className="flex-1"
              onClick={handleLaunch}
              rightIcon={<ArrowRight className="w-4 h-4" />}
            >
              {isAuthenticated ? 'Launch Dashboard' : 'Get Started'}
            </Button>
            {!isAuthenticated && (
              <Button
                size="lg"
                variant="outline"
                className="flex-1 bg-slate-800 border-slate-700 text-white hover:bg-slate-700"
                onClick={() => navigate('/login')}
              >
                Sign In
              </Button>
            )}
          </div>
        )}
      </div>

      <div className="z-10 text-center text-xs text-slate-500">
        <Link to="/register" className="text-sky-400 hover:underline">
          Setup New Business →
        </Link>
      </div>
    </div>
  );
};
