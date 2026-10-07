# Cursor handoff: event management and ticket sales

Act as my collaborative senior Ruby on Rails engineer and system-design partner. Help me build this project in small, understandable increments. This prompt transfers the decisions from an earlier planning conversation; it does not imply that a repository or implementation already exists.

## 1. My background and purpose

I am Greg, a software engineer with 7+ years of professional experience, primarily Ruby on Rails, with some Python, React/TypeScript and Hotwire experience. I am currently between jobs.

I want to build a complete application that I can publish on GitHub and host publicly on AWS. Potential employers should be able to try it, inspect the code and understand my engineering decisions.

My priorities are:
1. Demonstrate practical Rails/backend engineering and system-design ability.
2. Reinforce the concepts I have been practising so I can explain them confidently in interviews.
3. Gain hands-on experience integrating Stripe and deploying and operating an application on AWS.
4. Finish a coherent, reviewable product while keeping the scope manageable.
5. Enjoy building something in events and ticketing, an area I have experience and interest in.

Recent learning topics include Active Record and SQL, transactions and database constraints, locking and concurrency, background jobs, Ruby fundamentals, refactoring, design patterns, multi-tenancy, system design, failure handling and breaking features into tickets.

Do not treat me as a programming beginner. Explain unfamiliar infrastructure and design trade-offs clearly, and connect them to concrete behaviour.

## 2. Decisions already made

- The product is a generic event management and ticket sales application.
- The main deliverables are the application, a meaningful Stripe integration, a public GitHub repository and an AWS-hosted demonstration.
- This is primarily a portfolio and learning project. We are not currently validating a niche business or building a startup.
- Event organisers manage events and attendees; customers discover events and buy tickets.
- Social-network ideas have been deliberately saved for separate future projects.
- AI was discussed as a possible later extension. It is not required for the initial release and must not delay the core application.
- AWS experience is an explicit goal, including S3 and a useful Lambda workflow when appropriate.
- Technologies such as Redis and Kafka were discussed as possibilities, not requirements. Every service needs a concrete responsibility.

Do not restart product ideation or expand this into a social network, general appointment scheduler, equipment-rental system or all-purpose marketplace.

## 3. Proposed defaults, not previously finalised decisions

Use these as sensible starting assumptions. Briefly flag material alternatives; avoid a long questionnaire about reversible choices.

- Ruby on Rails monolith with clear responsibilities.
- PostgreSQL as the authoritative transactional datastore.
- Server-rendered views with Hotwire for interaction.
- RSpec for meaningful automated tests.
- Docker where it makes local setup and deployment reproducible.
- GitHub Actions for CI and eventually deployment.
- Single organiser business initially, with customer and staff roles.
- General-admission events with a fixed capacity.
- One ticket category per event initially; ticket tiers can follow.
- One currency initially, with EUR as a proposed default.
- Stripe sandbox/test payments for development and the public portfolio demo.
- Authentication required to purchase in the first version; guest checkout can follow.
- A clean, responsive interface with useful empty, loading and error states.

The project name, exact dependency versions, AWS account/region, hosting budget, final hosting topology and repository licence are still undecided. Use supported compatible versions, verify current official documentation, and pin the chosen versions. Respect an existing repository's conventions and dependencies.

For background jobs, Sidekiq with Redis is a reasonable learning-oriented default. Compare it briefly with a database-backed queue such as Solid Queue before choosing one. Do not operate multiple job backends merely to demonstrate more tools. PostgreSQL should enforce ticket inventory correctness.

## 4. Product scope

### First usable milestone
- Staff can create and publish an event with a title, description, location, event time zone, start/end times, capacity and ticket price.
- Customers can browse published events and view an event's details.
- Authorisation prevents customers from accessing organiser operations.
- Provide realistic synthetic seed data and a locally runnable app.

### First complete ticket-purchasing release
- A customer chooses a ticket quantity.
- The application temporarily holds that quantity and starts Stripe Checkout.
- Verified payment processing confirms the order and issues tickets.
- The customer can see their orders and tickets.
- Expired or abandoned unpaid reservations release capacity according to a defined policy.
- Staff can view orders, attendees and payment status.
- Confirmation delivery happens in the background.

### Subsequent milestones toward a polished portfolio release
- Documented cancellation rules and a full-refund workflow.
- Event cancellation with clear handling of existing purchases.
- A unique QR code or opaque token per ticket and an authorised check-in screen.
- Duplicate check-in prevention.
- Event images using Active Storage and S3.
- Basic sales and attendance reports.
- Deployment, monitoring and an operational runbook.

Multiple ticket categories, discounts, waitlists, recurring events, guest checkout, multiple organiser businesses, social features and AI are optional extensions. Do not build them before the end-to-end core works.

## 5. Business rules and design questions to resolve explicitly

Propose a minimal domain model from the workflows. Likely concepts include User, Event, Order, reservation/hold, Payment, Ticket and received payment events, but these are candidates rather than instructions to create a class for every noun.

Keep order, payment, inventory and ticket states understandable. Define valid transitions and the important invariants.

Work through these scenarios as the relevant feature is introduced:
- Two customers try to purchase the final available places.
- A user double-clicks purchase or retries after a timeout.
- Checkout-session creation succeeds remotely but the local request fails.
- A payment notification arrives more than once or in a different order.
- Payment succeeds but local processing fails.
- Payment success races with reservation expiry.
- Staff reduce capacity or change prices while orders exist.
- A customer cancels, a refund fails, or the refund result is initially uncertain.
- Two staff members scan the same ticket concurrently.
- A job retries after only part of its work completed.

Use database transactions, constraints and appropriate locking to protect invariants. Explain why a process-local Ruby Mutex or a model validation alone would not solve cross-process inventory races.

Persist purchase-time amounts and currency rather than recalculating historical purchases from an event's current price. Use integer minor units or an appropriate money representation, never floating-point arithmetic for money. Store timestamps consistently and retain the event's time zone for display and date rules.

Decide explicitly how cancellations and refunds affect ticket validity and resellable capacity. Do not silently assume these are always the same transition.

Do not invent infrastructure-heavy solutions before they are needed. Identify reliability gaps, implement a proportionate recovery mechanism, and document residual limitations.

## 6. Stripe integration expectations

Use the official SDK and current Stripe documentation. Begin with hosted Checkout and test payments for one organiser's Stripe account.

The integration should demonstrate:
- Server-side calculation and validation of prices, quantities and ownership.
- Signature verification using the webhook's raw request body.
- Persistent receipt of relevant events and safe asynchronous processing.
- Idempotent effects, including protection against issuing tickets twice.
- Correct handling of duplicate and out-of-order notifications.
- Idempotency keys for applicable outbound operations, with a documented retry strategy.
- Clear handling of failed, expired and cancelled checkout attempts.
- Reconciliation for cases where Stripe and local state temporarily disagree.
- Full refunds when that milestone is implemented.
- Useful logs without leaking secrets or unnecessary personal/payment data.

The browser success redirect is not authoritative proof of payment. A received event must not be considered fully processed before its business effects are safely applied.

Keep external network requests outside long-held database locks. Explain how the workflow recovers across separate database and provider operations rather than implying one transaction can cover both.

For the first release, choose payment methods and reservation-expiry behaviour together. Do not assume every enabled payment method settles immediately. Decide what happens if a late success arrives after capacity was released.

Multiple independent organisers collecting money would need a separate payment-account design, potentially Stripe Connect. It is not part of the single-organiser release.

## 7. AWS and DevOps goals

Keep AWS as the hosting destination. Do not substitute another provider merely because it is easier.

The previously suggested architecture was:
- Rails web application in a container on ECS/Fargate.
- PostgreSQL on RDS.
- S3 for uploaded images and exported files.
- CloudWatch for application logs, metrics and alarms.
- IAM roles and suitable secret management.
- A separate background process if the chosen queue requires it.

This is a proposed architecture, not an approved resource shopping list. Compare its learning value and running cost with a simpler AWS deployment before provisioning. Avoid infrastructure that the demo cannot justify.

Introduce infrastructure in stages. Get a minimal application deployed early, then expand it alongside the product.

S3 and Lambda should have real roles. A possible later Lambda exercise is producing a bounded image derivative after an upload. If Rails already performs that task, explain which path owns it rather than duplicating processing. Use distinct input/output prefixes or buckets to avoid a processing loop. SQS or Step Functions should enter only when a workflow benefits from their semantics.

Operational deliverables should include:
- Infrastructure as code, preferably Terraform unless there is a concrete reason otherwise.
- Reproducible builds and a documented deployment path.
- GitHub Actions deployment using scoped AWS OIDC credentials where appropriate.
- HTTPS, health checks, appropriate network boundaries and least-privilege access.
- Environment configuration and secrets outside the repository.
- A migration strategy and an application rollback procedure; address incompatible schema changes explicitly.
- Logs and metrics that help diagnose payment and job failures.
- Backups and an actual isolated restore exercise.
- A cost estimate for the chosen region, budget alerts, usage limits where applicable, log retention and cleanup instructions.

Resolve the account, region and spending budget before creating paid infrastructure. Prepare reviewable configuration and estimates first. Do not treat budget alerts as a hard spending cap or assume the deployment is free.

## 8. Engineering and testing standards

Prefer idiomatic Rails and simple, explicit code. Extract services, query objects, policies or adapters when they clarify responsibilities. Use design patterns in response to actual variation; do not manufacture a Factory, inheritance hierarchy, event bus or microservice split to showcase terminology.

Use meaningful tests for:
- Business rules and state transitions.
- Authentication and authorisation.
- Inventory contention using realistic database connections/concurrency.
- Stripe request boundaries and webhook processing.
- Duplicate execution and partial failure.
- Refund and check-in behaviour when implemented.
- At least one complete customer journey.

External integrations should be deterministic in CI. Keep separate documented sandbox/manual integration checks. Avoid a test suite that merely mirrors implementation details or a coverage target with little behavioural value.

Use realistic seed volumes to investigate one query-performance problem. Record reproducible conditions, query counts or timings and the effect of a change. Do not claim production scale or real-user performance from synthetic tests.

Use synthetic data, keep credentials out of Git, and clearly identify demo payments as test payments. The public demo needs sensible limits on expensive or externally visible actions.

## 9. Learning and portfolio presentation

I want to understand and be able to explain the code. Work in reviewable increments rather than generating the entire application in one pass.

For a significant feature:
1. State the requirement and its acceptance criteria.
2. Identify the important edge cases and invariant.
3. Explain the proposed approach and one realistic alternative.
4. Implement or help me implement the agreed-sized slice.
5. Run the relevant checks and report what was actually verified.
6. Give a brief interview explanation of the decision and its trade-off.

Use focused feedback and occasional questions to reinforce understanding without turning every message into a lecture. Offer exercises I can implement myself when useful. Do not conceal uncertainty, failures or limitations.

Keep the repository straightforward for a reviewer:
- README with purpose, screenshots, setup, test commands and demo information.
- A short guide pointing to a few interesting code paths.
- A compact architecture diagram and ER diagram.
- A small set of architecture decision records.
- Issues/tickets with acceptance criteria and dependencies.
- A runbook for deployment, failures and recovery.
- Honest notes about implemented features, deferred work and known limitations.

Document decisions as they are made; avoid generating a large pile of speculative documentation. Keep commits and changes coherent. Never claim a test, deployment, performance result or operational exercise succeeded unless it actually did.

## 10. Future scope and public code

Public GitHub visibility is intended. A particular open-source licence was not selected; do not silently choose MIT or another licence on my behalf. Licence selection should not block local development.

Future possibilities include multiple organiser businesses, ticket tiers, waitlists and a carefully scoped AI feature such as read-only event search or organiser reporting. If AI is added, use authorised source data, validated output, a small evaluation dataset and cost/latency tracking.

Social feeds, friend graphs, event memories and community features are explicitly deferred. Do not build their scaffolding now.

## 11. Start here

First inspect the current repository, project instructions and available development environment. Preserve existing work. Do not assume the directory is empty or that dependencies are installed.

Then:
1. Briefly restate the agreed goal and separate settled decisions from your working assumptions.
2. Propose a manageable sequence of milestones and the minimal starting architecture.
3. Outline the initial domain model without prematurely generating all of it.
4. Turn the first milestone into a few small tickets with clear acceptance criteria.
5. Identify the first useful vertical slice and proceed with its foundation when the environment permits. Keep the first implementation small enough to review.

Ask only questions that materially affect the next step. Use reasonable defaults for reversible choices and explain them. If credentials or infrastructure choices block a later stage, continue the local work that can be completed without them.

Useful official references to verify when implementing:
- Rails guides: https://guides.rubyonrails.org/
- Stripe Checkout: https://docs.stripe.com/payments/checkout
- Stripe webhooks: https://docs.stripe.com/webhooks
- Sidekiq best practices: https://github.com/sidekiq/sidekiq/wiki/Best-Practices
- ECS/Fargate: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
- S3-triggered Lambda: https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html
- GitHub Actions AWS OIDC: https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws

