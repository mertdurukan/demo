using Microsoft.EntityFrameworkCore;
using dev_api.Models;

namespace dev_api.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Varsayılan kullanıcı ekleme
            modelBuilder.Entity<User>().HasData(
                new User { Id = 1, Username = "admin", Password = "123456" }
            );
        }
    }
} 