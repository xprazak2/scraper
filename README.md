# Scraper

Scrapes data from pages

## Quickstart

```
bundle install
```
```
rails s 
```
```
curl -X GET -H "Content-Type: application/json"  http://localhost:3000/data  -d '{"url": "https://github.com/freerange/mocha", "fields": { "nav": ".sr-only", "meta": ["octolytics-url"]}}'
```
