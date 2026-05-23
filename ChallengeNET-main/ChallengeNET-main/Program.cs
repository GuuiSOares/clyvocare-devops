using ClyvoCare.API.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseOracle(builder.Configuration.GetConnectionString("OracleConnection")));
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

await InitializeDatabaseAsync(app);

app.UseSwagger();
app.UseSwaggerUI();

if (!app.Environment.IsEnvironment("Docker"))
{
    app.UseHttpsRedirection();
}

app.UseAuthorization();
app.MapControllers();
app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

app.Run();

static async Task InitializeDatabaseAsync(WebApplication app)
{
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    const int maxAttempts = 30;
    for (var attempt = 1; attempt <= maxAttempts; attempt++)
    {
        try
        {
            logger.LogInformation("Aplicando migrations Oracle (tentativa {Attempt}/{Max})...", attempt, maxAttempts);
            await db.Database.MigrateAsync();
            await DataSeeder.SeedAsync(db);
            logger.LogInformation("Banco Oracle inicializado com sucesso.");
            return;
        }
        catch (Exception ex) when (attempt < maxAttempts)
        {
            logger.LogWarning(ex, "Oracle ainda nao disponivel. Nova tentativa em 10s...");
            await Task.Delay(TimeSpan.FromSeconds(10));
        }
    }
}
