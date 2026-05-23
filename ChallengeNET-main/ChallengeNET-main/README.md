# 🐾 Clyvo Care API - Monitoramento Preditivo de Saúde Animal

O **Clyvo Care** é uma plataforma de Backend desenvolvida para revolucionar o acompanhamento veterinário. Através da coleta de dados biométricos em tempo real, a API permite que tutores e clínicas monitorem sinais vitais de pets, possibilitando a detecção precoce de anomalias através de análise inteligente de dados.

---

## 🛠️ Tecnologias Utilizadas

* **Runtime:** .NET 10 (ASP.NET Core API)
* **Banco de Dados:** Oracle Database (via Entity Framework Core)
* **Documentação:** Swagger / OpenAPI
* **Padrão de Projeto:** DTO (Data Transfer Objects) e validação robusta de dados via Data Annotations.

---

## 🚀 Instruções de Instalação e Execução
Configurar Banco de Dados:
As credenciais de acesso ao Oracle já estão configuradas no appsettings.json. Certifique-se de estar conectado à rede necessária para o acesso ao banco.

Aplicar Migrations:
No Console do Gerenciador de Pacotes do Visual Studio, execute:
Update-Database

Rodar a Aplicação:
Pressione F5 ou utilize o comando dotnet run no terminal.

Acessar a Interface Visual (MUITO IMPORTANTE):
Como esta é uma API RESTful pura, a raiz (/) retornará um erro 404 por padrão. Para visualizar e testar os endpoints através da interface gráfica, você deve acessar explicitamente a rota do Swagger.

Abra o navegador e acesse:
👉 https://localhost:7031/swagger (ou a porta gerada pelo seu Visual Studio)

### 📖 Documentação dos Endpoints (Swagger)
Abaixo está a explicação de como utilizar e testar cada funcionalidade disponível na interface do Swagger:

### 👤 Usuários (Tutores)
GET /api/Usuarios: Retorna a lista completa de tutores cadastrados.

GET /api/Usuarios/{id}: Busca os detalhes de um tutor específico pelo ID.

POST /api/Usuarios: Realiza o cadastro de um novo tutor. Utiliza o UsuarioCreateDTO para garantir que o e-mail seja válido e a senha tenha entre 6 e 20 caracteres.

PUT /api/Usuarios/{id}: Atualiza as informações cadastrais de um usuário existente.

DELETE /api/Usuarios/{id}: Remove permanentemente um tutor do sistema.

### 🐶 Pets
POST /api/Pets: Vincula um novo animal de estimação a um tutor existente. Exige um UsuarioId válido já cadastrado.

GET /api/Pets/especie/{especie}: Filtro Parametrizado para buscar todos os animais de uma espécie específica (ex: "Cachorro", "Gato").

GET /api/Pets/tutor/{usuarioId}: Retorna a lista de todos os pets que pertencem a um tutor específico.

GET /api/Pets/busca/{nome}: Realiza uma busca textual por parte do nome do pet (útil para campos de pesquisa em tempo real).

### 🩺 Logs de Saúde (Monitoramento & IoT)
POST /api/LogsSaude: Ponto de entrada que simula o recebimento de dados de sensores ou wearables. Recebe o peso, temperatura e batimentos cardíacos do pet. Possui validações contra dados absurdos (ex: temperatura fora da faixa de 30°C a 45°C).

GET /api/LogsSaude/pet/{petId}: Retorna o histórico cronológico de saúde de um pet específico, ordenado automaticamente do registro mais recente para o mais antigo.

### ⚠️ Regra de Negócio Importante (Vínculo de Entidades)
O sistema possui uma validação de integridade referencial por chave estrangeira (Foreign Key):
* **Cadastro de Pets:** Para cadastrar um pet com sucesso (`POST /api/Pets`), é **obrigatório** informar o ID de um tutor existente no campo `usuarioId`. Caso o ID informado não exista no banco de dados, a API barrará a operação e retornará uma mensagem de erro (`404 Not Found`), impedindo que existam pets órfãos no sistema.

### 🧠 Diferencial de IA e Negócio
A estrutura da tabela TB_CC_LOG_SAUDE armazena dados padronizados (NUMBER(10,2)) para evitar arredondamentos indesejados em medições críticas (como frações de peso e temperatura).

A ordenação decrescente na rota de histórico foi projetada para alimentar dashboards analíticos e modelos de Machine Learning (Predição de Risco). Ao cruzar esses dados históricos, o sistema consegue identificar tendências perigosas (como febre persistente ou perda repentina de peso) e disparar alertas preventivos antes que os sintomas clínicos se agravem.

## 📋 Regras de Negócio & Exemplos de Cadastro (JSON)

Para garantir a consistência dos dados coletados pela IA e a segurança do sistema, a API aplica regras estritas de validação em cada endpoint. Abaixo estão os formatos corretos de envio para testes no Swagger:

### 1. Cadastro de Usuário (Tutor)
* **Regra Importante:** O e-mail deve estar em um formato válido (`usuario@email.com`) e a senha **precisa ter entre 6 e 20 caracteres** (regra de segurança do `UsuarioCreateDTO`). Além disso, o e-mail atua como identificador único na regra de negócio.

* **Exemplo de JSON (`POST /api/Usuarios`):**
{
  "nome": "Carlos Andrade",
  "email": "carlos.tutor@email.com",
  "senha": "mypassword123"
}
### 2. Cadastro de Pet
Regra Importante: Só é permitido cadastrar um pet se o usuarioId enviado pertencer a um tutor já cadastrado no banco Oracle. A data de nascimento deve seguir o padrão ISO (AAAA-MM-DD).

Exemplo de JSON (POST /api/Pets):

JSON
{
  "nome": "Thor",
  "especie": "Cachorro",
  "dataNascimento": "2022-04-15",
  "usuarioId": 1
}
### 3. Registro de Logs de Saúde (Sensores / IoT)
Regras Importantes de Consistência para IA: 1. O petId precisa existir previamente.
2. Validação de Sinais Vitais: A temperatura possui uma trava de segurança ([Range(30, 45)]). Se o sensor ou usuário enviar uma temperatura absurda (ex: 12.0°C ou 80.0°C), a API rejeitará o cadastro para não poluir o histórico de dados com leituras falsas, protegendo a precisão dos modelos preditivos de Machine Learning.
3. A data e a hora do registro são geradas automaticamente pelo servidor no momento do envio.

Exemplo de JSON (POST /api/LogsSaude):

JSON
{
  "peso": 12.50,
  "temperatura": 38.60,
  "batimentosCardiacos": 110,
  "observacoes": "Dispositivo IoT coletou métricas normais durante o repouso.",
  "petId": 1
}

### ✒️ Integrantes:

Geovanne Coneglian Passos - RM: 562673

Lucas Silva Gastão Pinheiro - RM: 563960

Guilherme Soares De Almeida - RM: 563143
