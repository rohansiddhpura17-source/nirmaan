/**
 * NIRMAAN DESIGN SYSTEM TOKENS
 * Extracted directly from approved Figma specifications
 */

export const DesignTokens = {
  colors: {
    primaryNavy: '#0F172A',
    primaryDark: '#0A1128',
    primarySurface: '#1E293B',
    primaryLight: '#334155',

    brandBlue: '#0284C7',
    brandBlueLight: '#38BDF8',
    brandBlueDark: '#0369A1',
    brandBlueSubtle: '#E0F2FE',

    brandAmber: '#F59E0B',
    brandAmberLight: '#FEF3C7',
    brandAmberDark: '#D97706',

    surfaceLight: '#F8FAFC',
    surfaceWhite: '#FFFFFF',
    surfaceSubtle: '#F1F5F9',
    surfaceBorder: '#E2E8F0',

    success: '#10B981',
    successLight: '#D1FAE5',
    warning: '#F59E0B',
    warningLight: '#FEF3C7',
    error: '#EF4444',
    errorLight: '#FEE2E2',

    aiPurple: '#6366F1',
    aiPurpleLight: '#EEF2FF',
  },
  radii: {
    card: '16px',
    cardSm: '10px',
    cardLg: '24px',
    button: '10px',
    badge: '6px',
    chip: '9999px',
  },
  typography: {
    fontDisplay: '"Plus Jakarta Sans", "Inter", sans-serif',
    fontBody: '"Inter", system-ui, sans-serif',
  },
  breakpoints: {
    sm: '640px',
    md: '768px',
    lg: '1024px',
    xl: '1280px',
    '2xl': '1536px',
  },
} as const;
