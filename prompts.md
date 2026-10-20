[ROLE]
You are a senior full-stack engineer specializing in <tech stack>.

[CONTEXT]
Project: <Project Name>
Goal: <what you are building>
Users: <target users>
Constraints: <performance, security, cost, etc.>
Tech Stack: .NET 10, EF Core, PostgreSQL, Angular 17+
Architecture: 
-Backend: Clean Architecture
-Frontend: Standalone Components + Reactive Forms


[TASK]
Implement end-to-end <Feature Name>.
Implement data seeding for <Entity Name>.

[INPUT]
Feature Description:
<Explain feature>

DTO:
<your request/response model>

Business Rules:
- <rule 1>
- <rule 2>

UI Requirements:
- <UI behavior>
- <validation rules>

API:
GET /api/<endpoint>
POST /api/<endpoint>

Seed Requirements:
- Initial data: <describe data>
- Relationships: <if any>
- Volume: <e.g., 10 records / 1000 records>
- Environment-specific: Yes/No


[OUTPUT FORMAT]
- Code
- Folder structure
- Explanation (if needed)


Flow:
- Explain request → response lifecycle


[RULES]
Backend:
- Use async/await
- Handle transactions properly
- Avoid N+1 queries
- Follow SOLID principles
- Add proper error handling (global exception)
- Use dependency injection
- Use idempotent seeding (avoid duplicates)

Frontend:
- Use Reactive Forms
- Use RxJS best practices
- Handle API errors properly
- Keep component clean (move logic to service)
- Use async pipe where possible

[ANTI-PATTERNS]
Backend:
- Do not use synchronous DB calls
- Do not load full table in memory
- Avoid tight coupling
Frontend:
- No logic-heavy components
- Avoid nested subscriptions
- Avoid direct DOM manipulation