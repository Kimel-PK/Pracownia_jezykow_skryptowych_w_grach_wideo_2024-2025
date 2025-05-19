import json, os
from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher

day_translations = {
    "monday": "Poniedziałek",
    "tuesday": "Wtorek",
    "wednesday": "Środa",
    "thursday": "Czwartek",
    "friday": "Piątek",
    "saturday": "Sobota",
    "sunday": "Niedziela"
}

class ActionShowMenu(Action):
    def name(self) -> Text:
        return "action_show_menu"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        try:
            with open(os.path.join(os.getcwd(), 'data', 'menu.json'), 'r', encoding='utf-8') as f:
                menu = json.load(f)

            if not isinstance(menu, list):
                raise ValueError("Plik menu powinien zawierać listę dań")

            message_lines = [f"**Menu restauracji:**"]
            for item in menu:
                name = item.get("name", "Nieznane danie")
                price = item.get("price", "brak ceny")
                ingredients = ", ".join(item.get("ingredients", []))
                message_lines.append(f"   \n**{name}** ({price})\nSkładniki: {ingredients}")

            dispatcher.utter_message(text="\n".join(message_lines))

        except Exception as e:
            dispatcher.utter_message(text=f"Wystąpił nieoczekiwany błąd: {e}")

        return []

class ActionOpeningHours(Action):
    def name(self) -> Text:
        return "action_opening_hours"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        try:
            with open(os.path.join(os.getcwd(), 'data', 'opening_hours.json'), 'r', encoding='utf-8') as f:
                hours = json.load(f)

            message_lines = ["**Godziny otwarcia:**"]
            for day, hours_str in hours.items():
                status = "zamknięte" if hours_str.strip().lower() == "closed" else hours_str
                translated_day = day_translations.get(day.lower(), day)
                message_lines.append(f"{translated_day}: {status}")

            dispatcher.utter_message(text="\n".join(message_lines))

        except Exception as e:
            dispatcher.utter_message(text=f"Wystąpił nieoczekiwany błąd: {e}")

        return []