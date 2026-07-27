import {source} from '@/lib/source';
import {DocsLayout} from 'fumadocs-ui/layouts/docs';
import {baseOptions} from '@/lib/layout.shared';

export default function Layout({children}: LayoutProps<'/docs'>) {
    return (
        <DocsLayout
            tree={source.getPageTree()}
            {...baseOptions()}
            tabs={[
                {
                    title: 'biocentral',
                    url: '/docs',
                    description: 'Learn how to use the biocentral ecosystem',
                    icon: <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
                               stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <rect width="18" height="18" x="3" y="3" rx="2"/>
                        <path d="M3 9h18"/>
                        <path d="M9 21V9"/>
                    </svg>,
                },
                {
                    title: 'biocentral_api',
                    url: '/docs/biocentral_api',
                    description: 'Programmatic access to the biocentral ecosystem',
                    icon: <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
                               stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <rect width="20" height="16" x="2" y="4" rx="2"/>
                        <path d="M6 8h.01M10 8h.01M14 8h.01M18 8h.01M8 12h.01M12 12h.01M16 12h.01M7 16h10"/>
                    </svg>
                },
                {
                    title: 'biocentral IRE',
                    url: '/docs/biocentral-ire',
                    description: 'Desktop application for biocentral',
                    icon: <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
                               stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <line x1="12" y1="20" x2="12" y2="10"/>
                        <line x1="18" y1="20" x2="18" y2="4"/>
                        <line x1="6" y1="20" x2="6" y2="16"/>
                    </svg>
                },
                {
                    title: 'biocentral_server',
                    url: '/docs/biocentral_server',
                    description: 'The biocentral backend server',
                    icon: <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
                               stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <rect width="20" height="8" x="2" y="2" rx="2" ry="2"/>
                        <rect width="20" height="8" x="2" y="14" rx="2" ry="2"/>
                        <circle cx="8" cy="6" r="1"/>
                        <circle cx="8" cy="18" r="1"/>
                    </svg>
                },
                {
                    title: 'biotrainer',
                    url: '/docs/biotrainer',
                    description: 'Learn how to use the biotrainer package',
                    icon: <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
                               stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M12 2L2 7l10 5 10-5-10-5z"/>
                        <path d="M2 17l10 5 10-5"/>
                        <path d="M2 12l10 5 10-5"/>
                    </svg>
                },
            ]}
            {...baseOptions()}
        >
            {children}
        </DocsLayout>
    );
}
