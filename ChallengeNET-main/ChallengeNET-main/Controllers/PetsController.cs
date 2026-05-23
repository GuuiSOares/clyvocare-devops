using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ClyvoCare.API.Models;
using ClyvoCare.API.Data;
using ClyvoCare.API.DTOs;

namespace ClyvoCare.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PetsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PetsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Pets
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Pet>>> GetPet()
        {
            return await _context.Pets.ToListAsync();
        }

        // GET: api/Pets/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Pet>> GetPet(int id)
        {
            var pet = await _context.Pets.FindAsync(id);
            return pet == null ? NotFound() : pet;
        }

        // GET: api/Pets/especie/Cachorro
        [HttpGet("especie/{especie}")]
        public async Task<ActionResult<IEnumerable<Pet>>> GetPorEspecie(string especie)
        {
            return await _context.Pets
                .Where(p => p.Especie.ToLower() == especie.ToLower())
                .ToListAsync();
        }

        // GET: api/Pets/tutor/1
        [HttpGet("tutor/{usuarioId}")]
        public async Task<ActionResult<IEnumerable<Pet>>> GetPorTutor(int usuarioId)
        {
            return await _context.Pets
                .Where(p => p.UsuarioId == usuarioId)
                .ToListAsync();
        }

        // GET: api/Pets/busca/Thor
        [HttpGet("busca/{nome}")]
        public async Task<ActionResult<IEnumerable<Pet>>> GetPorNome(string nome)
        {
            return await _context.Pets
                .Where(p => p.Nome.Contains(nome))
                .ToListAsync();
        }

        // PUT: api/Pets/5
        // Atualiza os dados de identificação do pet (nome, espécie, etc)
        [HttpPut("{id}")]
        public async Task<IActionResult> PutPet(int id, Pet pet)
        {
            if (id != pet.Id) return BadRequest();

            _context.Entry(pet).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!PetExists(id)) return NotFound();
                else throw;
            }
            return NoContent();
        }

        // POST: api/Pets
        // Vincula e salva um novo pet associado a um Tutor (UsuarioId)
        [HttpPost]
        public async Task<ActionResult<Pet>> PostPet(PetCreateDTO petDto)
        {
            var pet = new Pet
            {
                Nome = petDto.Nome,
                Especie = petDto.Especie,
                DataNascimento = petDto.DataNascimento,
                UsuarioId = petDto.UsuarioId
            };

            _context.Pets.Add(pet);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetPet), new { id = pet.Id }, pet);
        }

        // DELETE: api/Pets/5
        // Exclui o pet do banco de dados utilizando o ID especificado
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePet(int id)
        {
            var pet = await _context.Pets.FindAsync(id);
            if (pet == null) return NotFound();

            _context.Pets.Remove(pet);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        private bool PetExists(int id)
        {
            return _context.Pets.Any(e => e.Id == id);
        }
    }
}