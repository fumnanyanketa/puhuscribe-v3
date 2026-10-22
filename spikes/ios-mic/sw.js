// Minimal service worker so Android offers "Install app". It caches nothing on purpose:
// the test must always load the latest page.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));
self.addEventListener('fetch', () => {});
