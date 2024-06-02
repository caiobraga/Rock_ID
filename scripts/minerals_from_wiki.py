import requests
from bs4 import BeautifulSoup

class Rock:
    def __init__(self, rockId, price, category, rockName, size, rating, humidity, temperature, imageURL, isFavorited, description, isSelected):
        self.rockId = rockId
        self.price = price
        self.category = category
        self.rockName = rockName
        self.size = size
        self.rating = rating
        self.humidity = humidity
        self.temperature = temperature
        self.imageURL = imageURL
        self.isFavorited = isFavorited
        self.description = description
        self.isSelected = isSelected

def scrape_rocks(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    rock_list = []
    rock_id = 1
    h2_elements = soup.find_all('h2')
    for h2 in h2_elements:
        category_span = h2.find('span', {'class': 'mw-headline'})
        if category_span:
            category = category_span.text.strip()
            ul = h2.find_next('ul')
            if ul:
                for li in ul.find_all('li'):
                    rock_name = li.find('a').get('title') if li.find('a') else li.text.strip()
                    description = li.text.strip()
                    # Creating dummy values for the fields not present in the source
                    rock_obj = Rock(
                        rockId=rock_id,
                        price=0,
                        category='mineral',
                        rockName=rock_name,
                        size='',
                        rating=0,
                        humidity=0,
                        temperature='',
                        imageURL='',
                        isFavorited=False,
                        description=description,
                        isSelected=False
                    )
                    rock_list.append(rock_obj)
                    rock_id += 1

    return rock_list

# Example usage
url = 'https://en.wikipedia.org/wiki/List_of_gemstones_by_species'
rocks = scrape_rocks(url)

# To save the rocks in the specified format to a text file
with open('rocks.txt', 'w', encoding='utf-8') as file:
    for rock in rocks:
        file.write(f"Rock(rockId: {rock.rockId}, price: {rock.price}, category: '{rock.category}', rockName: '{rock.rockName}', size: '{rock.size}', rating: {rock.rating}, humidity: {rock.humidity}, temperature: '{rock.temperature}', imageURL: '{rock.imageURL}', isFavorited: {rock.isFavorited}, description: '{rock.description}', isSelected: {rock.isSelected}),\n")