import discord, os
from rasa.core.agent import Agent
from rasa.utils.endpoints import EndpointConfig
from dotenv import load_dotenv

load_dotenv()

# ==== CONFIG ====
DISCORD_BOT_TOKEN = os.environ.get("DISCORD_TOKEN")
MODEL_NAME = "models/chatbot.tar.gz"
# ================

# Load Rasa model
agent = Agent.load(MODEL_NAME, action_endpoint=EndpointConfig(url="http://localhost:5055/webhook"))

# Discord bot setup
intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f'Logged in as {client.user}')

@client.event
async def on_message(message):
    if message.author == client.user:
        return

    try:
        async with message.channel.typing():
            response = await agent.handle_text(message.content)

        if response and isinstance(response, list) and 'text' in response[0]:
            await message.channel.send(response[0]['text'])
        else:
            await message.channel.send("Przepraszam, ale nie rozumiem tej wiadomości 😥")

    except Exception as e:
        print(f"Błąd podczas przetwarzania wiadomości: {e}")
        await message.channel.send("Wystąpił błąd podczas przetwarzania Twojej wiadomości.")

# Run the bot
client.run(DISCORD_BOT_TOKEN)
