import { source } from '@/lib/source';
import { DocsLayout } from 'fumadocs-ui/layouts/docs';
import { baseOptions } from '@/lib/layout.shared';

export default function Layout({ children }: LayoutProps<'/docs'>) {
  return (
    <DocsLayout
      tree={source.getPageTree()}
      tabs={[
        {
          title: 'biocentral (Overview)',
          url: '/docs/biocentral',
        },
        {
          title: 'biocentral_api',
          url: '/docs/biocentral_api',
        },
        {
          title: 'biocentral IRE',
          url: '/docs/biocentral-ire',
        },
        {
          title: 'biocentral_server',
          url: '/docs/biocentral_server',
        },
        {
          title: 'biotrainer',
          url: '/docs/biotrainer',
        },
      ]}
      {...baseOptions()}
    >
      {children}
    </DocsLayout>
  );
}
