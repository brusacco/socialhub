# SocialHub AI Coding Instructions

## AI Developer Role & Approach

Act as a senior Ruby on Rails developer. Your role is to analyze, debug, and resolve issues with accuracy and professionalism. To do so:

- Thoroughly review all provided code snippets and files. Never ask the user to confirm the presence of issues—assume full responsibility for identifying problems yourself.
- Verify the existence, context, and relevance of all referenced classes, methods, modules, routes, and database fields.
- Consult official Rails documentation and other authoritative sources to ensure every response is technically correct, current, and in line with best practices.
- Trace logical flows, identify edge cases, and consider side effects or unintended consequences in your debugging process.
- If an issue could be caused by version differences (e.g., Ruby, Rails, gems), consider version-specific behavior in your analysis.
- When suggesting solutions, explain why the fix works, and include any potential risks or trade-offs.
- Where helpful, suggest tests, logs, or additional tools to validate and monitor the fix.
- Your goal is to provide the most accurate, efficient, and production-ready solution, minimizing guesswork and maximizing clarity.

## Architecture Overview

SocialHub is a Rails 8 social media aggregation platform that manages profiles and their associated social accounts across multiple networks (Instagram, Facebook, TikTok, Twitter). The app uses ActiveAdmin for admin interface and follows a service-oriented architecture for API integrations.

### Core Data Architecture

The platform follows a hierarchical structure designed for consolidated social media reporting:

1. **Profile** (Main Entity): Central account profiles that represent individuals, brands, or organizations
2. **SocialAccount** (Network Integration): Multiple social network accounts per profile (Instagram, Facebook, X/Twitter, TikTok)
3. **SocialPost** (Future Model): Will store all posts from all networks, referencing their source social account

This design enables:

- **Consolidated Reporting**: Generate unified reports across all social networks for a profile
- **Network-Specific Analysis**: Detailed reporting per individual social network
- **Scalable Data Management**: Easy addition of new social networks without schema changes

## Core Models & Data Flow

- **Profile**: Central entity with `name`, `slug`, and `profile_type` enum - represents the main account (person, brand, organization)
- **SocialAccount**: Belongs to Profile, stores network-specific data with `network` enum (Instagram: 0, Facebook: 1, TikTok: 2, Twitter: 3)
- **SocialPost** (Planned): Will belong to SocialAccount, storing all posts from all networks for unified reporting
- **Data syncing**: `SocialAccount#update_profile_info` calls appropriate service based on network type

### Reporting Strategy

The hierarchical structure enables dual reporting capabilities:

- **Consolidated Reports**: Profile → All SocialAccounts → All SocialPosts (cross-network analytics)
- **Network-Specific Reports**: Profile → Specific SocialAccount → Network-specific SocialPosts

## Database Schema & Relations (Work in Progress)

### Current Tables & Structure

#### `profiles` (Core Entity)

- `name` (string, not null) - Display name
- `slug` (string, not null, unique) - URL-friendly identifier
- `profile_type` (integer, default: 0) - Enum: hombre(0), mujer(1), medio(2), marca(3), estatal(4), meme(5), programa(6)
- Standard Rails timestamps
- **Indexes**: name, profile_type, unique slug

#### `social_accounts` (Network Integration)

- `profile_id` (bigint, not null) - Foreign key to profiles
- `network` (integer, default: 0) - Enum: Instagram(0), Facebook(1), TikTok(2), Twitter(3)
- `uid` (string) - Network-specific user identifier
- `username` (string) - Handle/username on the network
- `display_name` (string) - Display name on the network
- `data` (JSON) - Flexible storage for API response data
- `followers` (integer, default: 0) - Follower count
- `following` (integer, default: 0) - Following count
- Standard Rails timestamps
- **Foreign Key**: references profiles table

#### `admin_users` (Authentication)

- Devise-managed table for ActiveAdmin authentication
- Standard Devise fields (email, encrypted_password, etc.)

#### `active_admin_comments` (Admin Interface)

- Polymorphic comments system for ActiveAdmin
- Links to any resource type via resource_type/resource_id

### Model Relations

- `Profile` has_many `:social_accounts` (dependent: :destroy)
- `Profile` accepts_nested_attributes_for `:social_accounts` (allow_destroy: true)
- `SocialAccount` belongs_to `:profile`

### Key Design Decisions

- **JSON Data Storage**: `social_accounts.data` column stores flexible API response data
- **Enum-based Networks**: Integer enums instead of polymorphic associations for performance
- **Nested Attributes**: ActiveAdmin forms handle multiple social accounts per profile
- **UTF8MB4**: MySQL charset supports full Unicode (emojis, international characters)

## Service Architecture Pattern

All external API integrations follow this strict pattern:

```ruby
module [Network]Services
  class GetProfileData < ApplicationService
    def initialize(identifier)
      @identifier = identifier
    end

    def call
      # API logic here
      handle_success(data) # or handle_error(message)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
```

**Key Points:**

- Services inherit from `ApplicationService` which provides `handle_success`/`handle_error` methods
- All services return `OpenStruct` with `success?`, `data`, and `error` attributes
- Call pattern: `ServiceName.call(params)` which instantiates and calls the service
- Use HTTParty for HTTP requests, not Net::HTTP

## External API Integrations

- **Facebook**: Graph API with hardcoded app token in `FacebookServices::GetProfileData`
- **TikTok**: TikApi.io with API key in `TikTokServices::GetProfileData`
- **Twitter**: Complex GraphQL endpoint with guest token authentication in `TwitterServices::GetProfileData`
- **Instagram**: Service structure exists but implementation varies

## ActiveAdmin Conventions

- Admin interfaces in `app/admin/` with nested social accounts forms
- Uses `permit_params` for nested attributes: `social_accounts_attributes: %i[id network username uid ...]`
- Filters and custom forms follow standard ActiveAdmin patterns

## Development Workflow

- **Start dev server**: `bin/dev` (runs web server + Tailwind watcher)
- **Database**: MySQL with schema in `db/schema.rb`
- **Styling**: Tailwind CSS with `bin/rails tailwindcss:watch`
- **Testing**: Standard Rails test suite structure
- **Linting**: RuboCop with Rails Omakase configuration

## Key Technical Decisions

- Rails 8 with modern stack (Hotwire, Stimulus, Importmap)
- Enum-based network identification instead of STI
- Service objects for API integrations with consistent error handling
- JSON storage in `data` column for flexible API response caching
- ActiveAdmin for rapid admin interface development

## Common Patterns

- API credentials hardcoded in service classes (not environment variables)
- Network identification by enum integer, not string
- Nested forms in ActiveAdmin for managing social accounts
- Error handling via OpenStruct return objects, not exceptions
- HTTParty preferred over Net::HTTP for HTTP requests

## Gem Dependencies & Purpose

### Core Framework

- **rails (~> 8.0.2)**: Latest Rails 8 with modern features (Hotwire, Propshaft, Solid adapters)
- **mysql2 (~> 0.5)**: MySQL database adapter for ActiveRecord
- **puma (>= 5.0)**: High-performance web server
- **bootsnap**: Reduces boot times through caching

### Frontend & Assets

- **propshaft**: Modern asset pipeline (replaces Sprockets)
- **importmap-rails**: JavaScript with ESM import maps (no bundling)
- **stimulus-rails**: Hotwire's modest JavaScript framework
- **turbo-rails**: Hotwire's SPA-like page accelerator
- **tailwindcss-rails** & **tailwindcss-ruby**: Utility-first CSS framework
- **cssbundling-rails**: CSS bundling for Tailwind integration
- **jbuilder**: JSON APIs builder

### Admin Interface

- **activeadmin (4.0.0.beta15)**: Admin interface framework (beta version)
- **activeadmin_assets (~> 1.0)**: Asset management for ActiveAdmin
- **devise (~> 4.9)**: Authentication solution for admin users

### External API Integration

- **httparty (~> 0.23.1)**: HTTP client for all social media API calls
  - Used in all `*Services::GetProfileData` classes
  - Preferred over Net::HTTP for simplicity and consistency

### Background Processing & Caching

- **solid_queue**: Database-backed Active Job adapter (Rails 8 feature)
- **solid_cache**: Database-backed Rails.cache (Rails 8 feature)
- **solid_cable**: Database-backed Action Cable (Rails 8 feature)

### Development & Testing

- **debug**: Ruby debugger (replaces byebug/pry)
- **web-console**: Interactive console on exception pages
- **capybara** & **selenium-webdriver**: System testing framework

### Code Quality & Security

- **rubocop-rails-omakase**: Rails Omakase Ruby styling (primary linter)
- **rubocop** family: Additional linting rules (capybara, performance, rails, rspec)
- **brakeman**: Static security vulnerability analysis

### Deployment

- **kamal**: Docker-based deployment tool (Rails 8 default)
- **thruster**: HTTP asset caching/compression for Puma

## File Organization

- Services: `app/services/[network]_services/get_profile_data.rb`
- Admin interfaces: `app/admin/[model_plural].rb`
- Models use `frozen_string_literal: true` and follow Rails conventions
