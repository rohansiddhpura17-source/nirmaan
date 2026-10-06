/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        navy: {
          900: '#0F172A',
          800: '#1E293B',
          700: '#334155',
          950: '#0A1128',
        },
        brand: {
          blue: '#0284C7',
          'blue-light': '#38BDF8',
          'blue-dark': '#0369A1',
          'blue-subtle': '#E0F2FE',
          amber: '#F59E0B',
          'amber-light': '#FEF3C7',
          'amber-dark': '#D97706',
        },
        surface: {
          light: '#F8FAFC',
          white: '#FFFFFF',
          subtle: '#F1F5F9',
          border: '#E2E8F0',
        },
        ai: {
          purple: '#6366F1',
          'purple-light': '#EEF2FF',
          glow: 'rgba(99, 102, 241, 0.15)',
        }
      },
      borderRadius: {
        'nirmaan': '16px',
        'nirmaan-sm': '10px',
        'nirmaan-lg': '24px',
      },
      fontFamily: {
        sans: ['Inter', 'Plus Jakarta Sans', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        'card': '0 1px 3px 0 rgba(0, 0, 0, 0.05), 0 1px 2px -1px rgba(0, 0, 0, 0.05)',
        'card-hover': '0 4px 6px -1px rgba(0, 0, 0, 0.08), 0 2px 4px -2px rgba(0, 0, 0, 0.05)',
        'ai-card': '0 0 0 1px rgba(99, 102, 241, 0.15), 0 4px 12px rgba(99, 102, 241, 0.06)',
      }
    },
  },
  plugins: [],
}
