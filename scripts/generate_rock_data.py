import requests
import json
import re
import time


class Rock:
    def __init__(self, rockId, price, size, rating, humidity, temperature, category, rockName, imageURL, isFavorited, description, isSelected, formula, hardness, color, isMagnetic, healthRisks, askedQuestions, crystalSystem, Colors, Luster, Diaphaneity, quimicalClassification, elementsListed, healingPropeties, formulation, meaning, howToSelect, types, uses):
        self.rockId = rockId
        self.price = price
        self.size = size
        self.rating = rating
        self.humidity = humidity
        self.temperature = temperature
        self.category = category
        self.rockName = rockName
        self.imageURL = imageURL
        self.isFavorited = isFavorited
        self.description = description
        self.isSelected = isSelected
        self.formula = formula
        self.hardness = hardness
        self.color = color
        self.isMagnetic = isMagnetic
        self.healthRisks = healthRisks
        self.askedQuestions = askedQuestions
        self.crystalSystem = crystalSystem
        self.Colors = Colors
        self.Luster = Luster
        self.Diaphaneity = Diaphaneity
        self.quimicalClassification = quimicalClassification
        self.elementsListed = elementsListed
        self.healingPropeties = healingPropeties
        self.formulation = formulation
        self.meaning = meaning
        self.howToSelect = howToSelect
        self.types = types
        self.uses = uses



class ChatGPTService:
    def __init__(self, apiKey):
        self.apiKey = apiKey

    def fetch_rock_details(self, rockName):
        url = "https://api.openai.com/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {self.apiKey}",
            "Content-Type": "application/json",
        }

        body = {
            "model": "gpt-4",
            "messages": [
                {
                    "role": "system",
                    "content": "You are a knowledgeable assistant that provides detailed information about rocks."
                },
                {
                    "role": "user",
                    "content": f"""
                Provide detailed information about the rock named '{rockName}', including fields such as health risks, asked questions, crystal system, colors, luster, diaphaneity, chemical classification, elements listed, healing properties, formulation, meaning, how to select, types, and uses. The information should be formatted in a JSON format. Ensure the JSON is properly formatted and follows standard conventions. Here is an example format:
                {{
                    "rockId": 1,
                    "price": 0,
                    "size": "",
                    "rating": 0,
                    "humidity": 0.0,
                    "temperature": "",
                    "category": "mineral",
                    "rockName": "Quartz",
                    "imageURL": "",
                    "isFavorited": false,
                    "description": "Quartz is one of the most abundant and varied minerals on earth. It's also one of the most used due to its functional and aesthetic properties.",
                    "isSelected": false,
                    "formula": "SiO2",
                    "hardness": 7.0,
                    "color": "clear, pink (rose quartz), purple (amethyst), brown/black (smoky quartz), yellow (citrine), white (milky quartz)",
                    "isMagnetic": false,
                    "healthRisks": "",
                    "askedQuestions": [],
                    "crystalSystem": "Trigonal",
                    "Colors": "clear, pink, purple, brown/black, yellow, white",
                    "Luster": "Vitreous",
                    "Diaphaneity": "Transparent to translucent",
                    "chemicalClassification": "Silicate",
                    "elementsListed": "Silicon, Oxygen",
                    "healingProperties": "Healing and amplifying energy, promoting clarity of mind, promoting positivity",
                    "formulation": "SiO2",
                    "meaning": "Healing and amplifying energy, promoting clarity of mind, promoting positivity",
                    "howToSelect": "When selecting quartz for spiritual healing, it's important to choose a piece that you're intuitively drawn to.",
                    "types": "Rose Quartz, Amethyst, Smoky Quartz, Citrine, Milky Quartz",
                    "uses": "Jewelry, industrial applications, spiritual healing"
                }}"""
                }
            ],
            "temperature": 1,
            "max_tokens": 1024,  # Increase max_tokens to handle large responses
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 0
        }

        response = requests.post(url, headers=headers, data=json.dumps(body))

        if response.status_code == 200:
            response_body = response.json()
            response_string = response_body['choices'][0]['message']['content'].replace("```json", "").replace("```", "").strip()

            # Fix any incorrect escape sequences
            response_string = re.sub(r'\\\\"', r'\\"', response_string)
            response_string = response_string.replace('\\"', '"')

            # Fix specific issues
            response_string = re.sub(r'(\d+)\-(\d+)', r'\1-\2', response_string)  # Fix hyphens in numbers
            #response_string = re.sub(r"(?<!\\)'", r'"', response_string)  # Replace single quotes with double quotes
            response_string = re.sub(r'(\d+)\-(\d+)', r'"\1-\2"', response_string)  # Wrap numbers with hyphens in quotes

            # Manually ensure proper JSON formatting by adding missing commas
            response_string = re.sub(r'(\s*"[a-zA-Z]+":\s*".+?")(\s*")', r'\1,\2', response_string)

            try:
                return json.loads(response_string)
            except json.JSONDecodeError as e:
                print(f"JSON decoding error: {e}")
                print(f"Response string: {response_string}")
                with open('failed.txt', 'a', encoding='utf-8') as fail_file:
                    fail_file.write(f"${rockName}/n")
                return None
        else:
            print(f'Request failed with status: {response.status_code}')
            print(f'Response: {response.text}')
            return None
        time.sleep(2)

def populate_rocks():
    chatgpt_service = ChatGPTService(apiKey='')
    rock_names = [
"Peridotite",
"Itacolumite",
"Greenschist",
"Calcflinta",
"Azurmalachite",
"Baryte",
"Beryl",
"Emerald",
"Beryllonite",
"Biotite",
"Brookite",
"Bustamite",
"Emerald",
"Garnet",
"Opal",
"Ammolite",
"Bone",
"Seashell",
"Anyolite",
"Bauxite",
"Beryl",
"Emerald",
"Heliodor",
"Morganite",
"Beryllonite",
"Diaspore",
"Garnet",
"Kornerupine",
"Kyanite",
"Opal",
"Peridot",
"Phenakite",
"Rhodonite",
"Bowenite",
]
    rocks = []

    rock_id = 1
    for rock_name in rock_names:
        print(f"Fetching details for rock: {rock_name}")
        details = chatgpt_service.fetch_rock_details(rock_name)
        print(details)
        if details:
            rock = Rock(
                rockId=rock_id,
                price=details.get('price', 0),
                size=details.get('size', ''),
                rating=details.get('rating', 0),
                humidity=details.get('humidity', 0.0),
                temperature=details.get('temperature', ''),
                category=details.get('category', ''),
                rockName=rock_name,
                imageURL=details.get('imageURL', ''),
                isFavorited=details.get('isFavorited', False),
                description=details.get('description', ''),
                isSelected=details.get('isSelected', False),
                formula=details.get('formula', ''),
                hardness=details.get('hardness', 0.0),
                color=details.get('color', ''),
                isMagnetic=details.get('isMagnetic', False),
                healthRisks=details.get('healthRisks', ''),
                askedQuestions=details.get('askedQuestions', []),
                crystalSystem=details.get('crystalSystem', ''),
                Colors=details.get('Colors', ''),
                Luster=details.get('Luster', ''),
                Diaphaneity=details.get('Diaphaneity', ''),
                quimicalClassification=details.get('quimicalClassification', ''),
                elementsListed=details.get('elementsListed', ''),
                healingPropeties=details.get('healingPropeties', ''),
                formulation=details.get('formulation', ''),
                meaning=details.get('meaning', ''),
                howToSelect=details.get('howToSelect', ''),
                types=details.get('types', ''),
                uses=details.get('uses', '')
            )
            with open('rocks_generated.txt', 'a', encoding='utf-8') as file:
                file.write(f'Rock(rockId: {rock.rockId}, price: {rock.price}, size: "{rock.size}", rating: {rock.rating}, humidity: {rock.humidity}, temperature: "{rock.temperature}", category: "{rock.category}", rockName: "{rock.rockName}", imageURL: "{rock.imageURL}", isFavorited: {rock.isFavorited}, description: "{rock.description}", isSelected: {rock.isSelected}, formula: "{rock.formula}", hardness: {rock.hardness}, color: "{rock.color}", isMagnetic: {rock.isMagnetic}, healthRisks: "{rock.healthRisks}", askedQuestions: {rock.askedQuestions}, crystalSystem: "{rock.crystalSystem}", colors: "{rock.Colors}", luster: "{rock.Luster}", diaphaneity: "{rock.Diaphaneity}", quimicalClassification: "{rock.quimicalClassification}", elementsListed: "{rock.elementsListed}", healingPropeties: "{rock.healingPropeties}", formulation: "{rock.formulation}", meaning: "{rock.meaning}", howToSelect: "{rock.howToSelect}", types: "{rock.types}", uses: "{rock.uses}"),\n')
            rocks.append(rock)
            rock_id += 1
        else:
            print(f"Failed to fetch details for rock: {rock_name}")
        time.sleep(2)
    
    return rocks

# Example usage
rocks = populate_rocks()

# Save the rocks in the specified format to a text file
#with open('rocks_generated.txt', 'w', encoding='utf-8') as file:
#    for rock in rocks:
#        file.write(f"Rock(rockId: {rock.rockId}, price: {rock.price}, size: '{rock.size}', rating: {rock.rating}, humidity: {rock.humidity}, temperature: '{rock.temperature}', category: '{rock.category}', rockName: '{rock.rockName}', imageURL: '{rock.imageURL}', isFavorited: {rock.isFavorited}, description: '{rock.description}', isSelected: {rock.isSelected}, formula: '{rock.formula}', hardness: {rock.hardness}, color: '{rock.color}', isMagnetic: {rock.isMagnetic}, healthRisks: '{rock.healthRisks}', askedQuestions: {rock.askedQuestions}, crystalSystem: '{rock.crystalSystem}', Colors: '{rock.Colors}', Luster: '{rock.Luster}', Diaphaneity: '{rock.Diaphaneity}', quimicalClassification: '{rock.quimicalClassification}', elementsListed: '{rock.elementsListed}', healingPropeties: '{rock.healingPropeties}', formulation: '{rock.formulation}', meaning: '{rock.meaning}', howToSelect: '{rock.howToSelect}', types: '{rock.types}', uses: '{rock.uses}'),\n")