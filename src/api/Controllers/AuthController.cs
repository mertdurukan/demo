using Microsoft.AspNetCore.Mvc;
using dev_api.Data;
using dev_api.Models;

namespace dev_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuthController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest request)
        {
            var user = _context.Users.FirstOrDefault(u => 
                u.Username == request.Username && u.Password == request.Password);

            if (user == null)
            {
                return Unauthorized(new { message = "Kullanıcı adı veya şifre hatalı" });
            }

            return Ok(new { 
                message = "Giriş başarılı", 
                userId = user.Id, 
                username = user.Username 
            });
        }
    }

    public class LoginRequest
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }
} 