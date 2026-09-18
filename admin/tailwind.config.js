/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        // The platform's own palette, from lib/theme/tokens.dart. The portal is
        // the same product seen from the other side, so it uses the same ink.
        ink: '#10312B',
        teal: { DEFAULT: '#0F5257', soft: '#E4EFEC' },
        terra: { DEFAULT: '#D2603F', soft: '#FBEAE3' },
        paper: '#F7F2EA',
        divider: '#E6DED2',
        soft: '#5E6E6A',
        // Semantic only — red and amber never decorate anything here either.
        danger: { DEFAULT: '#B23A32', soft: '#F7E4E2' },
        warn: { DEFAULT: '#C98A2B', soft: '#FBF0DC' },
        good: { DEFAULT: '#3E7C59', soft: '#E3F0E8' },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'Segoe UI', 'Roboto', 'sans-serif'],
        mono: ['ui-monospace', 'SFMono-Regular', 'Menlo', 'monospace'],
      },
    },
  },
  plugins: [],
}
