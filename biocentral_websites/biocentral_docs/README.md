# biocentral_docs

## Development

This is a Next.js application generated with
[Create Fumadocs](https://github.com/fuma-nama/fumadocs).

Run development server:

```bash
npm install
npm run dev
```

Open http://localhost:3000 with your browser to see the result.

## Docker

Build and run the optimized standalone image locally:

```bash
docker build -t biocentral-docs .
docker run --rm -p 3000:3000 biocentral-docs
```

