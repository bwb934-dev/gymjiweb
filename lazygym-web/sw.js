/**
 * Service Worker for LazyGym Web App
 * Provides offline functionality and caching
 */

const CACHE_NAME = 'lazygym-v1.0.0';
const urlsToCache = [
    '/',
    '/index.html',
    '/styles.css',
    '/js/models.js',
    '/js/dataManager.js',
    '/js/progressionCalculator.js',
    '/js/ui.js',
    '/js/app.js',
    'https://cdn.jsdelivr.net/npm/chart.js',
    'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap'
];

// Install event
self.addEventListener('install', event => {
    console.log('Service Worker installing...');
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => {
                console.log('Service Worker caching files');
                return cache.addAll(urlsToCache);
            })
            .catch(error => {
                console.error('Service Worker cache failed:', error);
            })
    );
    self.skipWaiting();
});

// Activate event
self.addEventListener('activate', event => {
    console.log('Service Worker activating...');
    event.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cacheName => {
                    if (cacheName !== CACHE_NAME) {
                        console.log('Service Worker deleting old cache:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
    self.clients.claim();
});

// Fetch event
self.addEventListener('fetch', event => {
    // Skip non-GET requests
    if (event.request.method !== 'GET') {
        return;
    }
    
    // Skip chrome-extension and other non-http requests
    if (!event.request.url.startsWith('http')) {
        return;
    }
    
    event.respondWith(
        caches.match(event.request)
            .then(response => {
                // Return cached version or fetch from network
                if (response) {
                    console.log('Service Worker serving from cache:', event.request.url);
                    return response;
                }
                
                console.log('Service Worker fetching from network:', event.request.url);
                return fetch(event.request).then(response => {
                    // Check if we received a valid response
                    if (!response || response.status !== 200 || response.type !== 'basic') {
                        return response;
                    }
                    
                    // Clone the response
                    const responseToCache = response.clone();
                    
                    caches.open(CACHE_NAME)
                        .then(cache => {
                            cache.put(event.request, responseToCache);
                        });
                    
                    return response;
                }).catch(error => {
                    console.log('Service Worker fetch failed:', error);
                    
                    // Return offline page for navigation requests
                    if (event.request.destination === 'document') {
                        return caches.match('/index.html');
                    }
                });
            })
    );
});

// Message event for communication with main thread
self.addEventListener('message', event => {
    if (event.data && event.data.type === 'SKIP_WAITING') {
        self.skipWaiting();
    }
});

// Background sync (if supported)
self.addEventListener('sync', event => {
    if (event.tag === 'background-sync') {
        console.log('Service Worker background sync');
        // Handle background sync if needed
    }
});

// Push notification (if needed in future)
self.addEventListener('push', event => {
    if (event.data) {
        const data = event.data.json();
        console.log('Service Worker push notification:', data);
        
        const options = {
            body: data.body,
            icon: '/icon-192.png',
            badge: '/icon-192.png',
            vibrate: [100, 50, 100],
            data: data.data,
            actions: [
                {
                    action: 'explore',
                    title: 'View Details',
                    icon: '/icon-192.png'
                },
                {
                    action: 'close',
                    title: 'Close',
                    icon: '/icon-192.png'
                }
            ]
        };
        
        event.waitUntil(
            self.registration.showNotification(data.title, options)
        );
    }
});

// Notification click
self.addEventListener('notificationclick', event => {
    console.log('Service Worker notification click:', event);
    
    event.notification.close();
    
    if (event.action === 'explore') {
        // Open the app
        event.waitUntil(
            clients.openWindow('/')
        );
    }
});

console.log('Service Worker loaded successfully');
