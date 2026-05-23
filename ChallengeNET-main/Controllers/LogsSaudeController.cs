using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ClyvoCare.API.Models;
using ClyvoCare.API.Data;
using ClyvoCare.API.DTOs;

namespace ClyvoCare.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LogsSaudeController : ControllerBase
    {
        private readonly AppDbContext _context;

        public LogsSaudeController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/LogsSaude
        [HttpGet]
        public async Task<ActionResult<IEnumerable<LogSaude>>> GetLogSaude()
        {
         
            if (!_context.Usuarios.Any())
            {
                return new List<LogSaude>();
            }

            return await _context.LogsSaude.ToListAsync();
        }

        // GET: api/LogsSaude/pet/1
        [HttpGet("pet/{petId}")]
        public async Task<ActionResult<IEnumerable<LogSaude>>> GetLogsPorPet(int petId)
        {
            return await _context.LogsSaude
                .Where(l => l.PetId == petId)
                .OrderByDescending(l => l.DataHora)
                .ToListAsync();
        }

        // POST: api/LogsSaude
        // Grava as métricas de saúde enviadas por sensores IoT, aplicando data e hora automáticas
        [HttpPost]
        public async Task<ActionResult<LogSaude>> PostLogSaude(LogSaudeCreateDTO dto)
        {
            var log = new LogSaude
            {
                Peso = dto.Peso,
                Temperatura = dto.Temperatura,
                BatimentosCardiacos = dto.BatimentosCardiacos,
                Observacoes = dto.Observacoes,
                PetId = dto.PetId,
                DataHora = DateTime.Now
            };

            _context.LogsSaude.Add(log);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetLogSaude), new { id = log.Id }, log);
        }
    }
}