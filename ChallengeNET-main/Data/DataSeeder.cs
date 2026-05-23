using ClyvoCare.API.Models;
using Microsoft.EntityFrameworkCore;

namespace ClyvoCare.API.Data;

public static class DataSeeder
{
    public static async Task SeedAsync(AppDbContext context)
    {
        if (await context.Usuarios.CountAsync() > 0)
        {
            return;
        }

        var tutor = new Usuario
        {
            Nome = "Carlos Andrade",
            Email = "carlos.tutor@clyvocare.com.br",
            Senha = "mypassword123"
        };

        context.Usuarios.Add(tutor);
        await context.SaveChangesAsync();

        var pet = new Pet
        {
            Nome = "Thor",
            Especie = "Cachorro",
            DataNascimento = new DateTime(2022, 4, 15),
            UsuarioId = tutor.Id
        };

        context.Pets.Add(pet);
        await context.SaveChangesAsync();

        context.LogsSaude.Add(new LogSaude
        {
            Peso = 12.50m,
            Temperatura = 38.60m,
            BatimentosCardiacos = 110,
            Observacoes = "Dispositivo IoT coletou metricas normais durante o repouso.",
            PetId = pet.Id,
            DataHora = DateTime.UtcNow
        });

        await context.SaveChangesAsync();
    }
}
