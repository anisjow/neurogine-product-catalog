# Neurogine Product Catalog

A Flutter product catalog app built for the Neurogine Junior Mobile Developer technical assessment.

## Features

- Product listing from DummyJSON API
- Pagination using `skip`
- Product search with 500ms debounce
- Product detail screen
- Loading, error, empty and success states
- Retry button for failed requests
- Pull-to-refresh
- Image error placeholder
- Image error placeholder
- Hero animation and visual star rating
- Unit test for `Product.fromJson`

## Tech Stack

- Flutter
- Dart
- HTTP package
- DummyJSON API

## Architecture

The project uses a simple two-layer structure:

- `data` - contains models and API services
- `presentation` - contains screens and UI

## Unfinished Work / Future Improvements

- Add more unit tests for API service and UI interactions.
- Further improve the UI and user experience.