using Microsoft.EntityFrameworkCore;
using dev_api.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// ================================
// HEALTH CHECKS
// ================================
// Neden: Docker container'ların sağlık durumunu kontrol et
builder.Services.AddHealthChecks();

// ================================
// ENTITY FRAMEWORK
// ================================
// Connection string'i environment'tan al
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=(localdb)\\mssqllocaldb;Database=DevApiDb;Trusted_Connection=true;MultipleActiveResultSets=true";

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

// CORS - Tüm origin'lere izin ver (Development için)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Veritabanını oluştur
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    context.Database.EnsureCreated();
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowFrontend");

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

// ================================
// HEALTH CHECK ENDPOINT
// ================================
// Neden: Docker health check için endpoint
app.MapHealthChecks("/health");

app.Run();
