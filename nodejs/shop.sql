-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Maj 20, 2025 at 09:26 PM
-- Wersja serwera: 10.4.27-MariaDB
-- Wersja PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `shop`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` longtext DEFAULT NULL,
  `imgUrl` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `description`, `imgUrl`) VALUES
(1, 'Bread', '<p>Bread is one of the oldest and most fundamental foods, made from a mixture of flour, water, and usually yeast, which is then baked. It comes in many shapes, sizes, and flavors, ranging from light and fluffy loaves to dense, hearty artisanal breads. Whether enjoyed fresh from the oven, toasted with butter, or as the base of a delicious sandwich, bread has been a staple in diets around the world for thousands of years. It symbolizes comfort, tradition, and the art of simple yet satisfying nourishment.</p>', 'https://cdn.pixabay.com/photo/2017/10/18/16/44/bread-2864703_960_720.jpg'),
(2, 'Rolls', '<p>Rolls are small, individual portions of bread that are soft on the inside and often have a slightly crispy crust. They come in various shapes, such as round, oval, or even square, and are a versatile side dish perfect for any meal. Whether served warm with butter, as a base for sandwiches, or as a complement to soups and salads, rolls offer a comforting and flavorful bite. Their delicate texture and simple ingredients make them a favorite in kitchens worldwide, from family dinners to fancy banquets.</p>', 'https://cdn.pixabay.com/photo/2018/06/10/20/30/bread-3467243_960_720.jpg');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `phoneNumber` varchar(255) DEFAULT NULL,
  `productsList` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` longtext DEFAULT NULL,
  `imgUrl` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `categoryId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `description`, `imgUrl`, `price`, `categoryId`) VALUES
(1, 'Wheat bread', '<h1>White Bread: The Cloud of the Culinary World</h1>\n\n  <p><strong>White bread</strong> is more than just a staple food—it\'s a symbol of civilization, a testament to our collective desire for softness, and the fluffy embodiment of human ambition. Crafted from refined wheat flour, white bread is famed for its tender texture, pale coloration, and uncanny ability to mold itself into sandwich perfection.</p>\n\n  <h2>Historical Significance</h2>\n  <p>White bread was allegedly discovered by accident in 1283, when a French alchemist attempted to transmute wheat into gold and instead invented a supremely soft loaf. Monarchs of the time, upon tasting it, immediately declared it \"the most edible throne cushion ever conceived.\"</p>\n\n  <p>It is also said that <em>Leonardo da Vinci</em> once painted with white bread soaked in olive oil, claiming it provided “a texture more divine than the Mona Lisa’s smile.”</p>\n\n  <h2>Nutritional Profile</h2>\n  <p>White bread is a curious creature of the nutrition world. Each slice contains:</p>\n  <ul>\n    <li>Approximately 70 calories</li>\n    <li>A whisper of fiber</li>\n    <li>Enough carbohydrates to power a small hamster for eight days</li>\n    <li>0.0003% unicorn dust (unconfirmed by scientists)</li>\n  </ul>\n\n  <h2>Fake But Fascinating Facts</h2>\n  <ol>\n    <li>In 1834, white bread was used as legal currency in at least three secret baker republics hidden in the Alps.</li>\n    <li>White bread is the only known food that can survive a black hole. NASA once tested this by throwing a sandwich into one—no crumbs were recovered, but the gravitational field reportedly smelled like toast for three months.</li>\n    <li>A slice of white bread can be folded precisely 42 times, at which point it opens a portal to the Yeast Realm.</li>\n    <li>Einstein once claimed, “If relativity is proven wrong, I shall resort to baking white bread professionally.”</li>\n    <li>The Beatles almost named their band \"The White Breads\" before settling on their final moniker.</li>\n  </ol>\n\n  <h2>Uses Beyond Eating</h2>\n  <p>Aside from its obvious culinary uses, white bread has been creatively employed in many unconventional ways:</p>\n  <ul>\n    <li>As insulation in emergency igloos built by Arctic bakers</li>\n    <li>As a sponge for absorbing emotional trauma during particularly sad movies</li>\n    <li>As a low-budget alternative to pillows in some avant-garde hostels</li>\n    <li>As a time-travel stabilizer in early steampunk experiments (source needed)</li>\n  </ul>\n\n  <h2>Conclusion</h2>\n  <p>White bread is not just a food—it is a journey. From its ethereal fluffiness to its fictional feats of scientific defiance, it stands as a loaf-shaped enigma in the pantry of humanity. Whether toasted, buttered, or used to fight entropy itself, one thing is certain:</p>\n\n  <blockquote>\n    \"All loaves lead to white bread eventually.\" – Ancient Yeasterian Proverb\n  </blockquote>\n', 'https://cdn.pixabay.com/photo/2016/07/11/17/31/bread-1510155_960_720.jpg', 3.49, 1),
(2, 'Minecraft bread', '<h1>Minecraft Bread: The Golden Loaf of Blocky Survival</h1> <p><strong>Minecraft bread</strong> is not merely a pixelated food item—it is a culinary cornerstone, a carbohydrate champion, and the humble hero of blocky sustenance. Forged from three perfectly aligned bundles of wheat, this square-shaped savior has kept countless miners alive during Creeper ambushes and suspicious cave dives.</p> <h2>Historical Origins</h2> <p>Minecraft bread first appeared when a blocky farmer accidentally dropped three wheat stalks on a crafting table during a full redstone moon. Legend claims that the first loaf baked itself instantly, emerging with a faint glow and the soft sound of mooing in the distance.</p> <p>Some scholars insist that ancient Villagers once worshipped the bread, placing it atop obsidian altars and chanting, “Loaf be praised.” Others argue it was Notch himself who baked the original loaf using the warmth of a thousand torches.</p> <h2>Nutrition, Minecraft Style</h2> <p>Each loaf of Minecraft bread offers:</p> <ul> <li>5 hunger points restored (approximately 83% of a full stomach, or one cow\'s worth of joy)</li> <li>Zero crumbs (due to efficient pixel packing)</li> <li>A gluten content so refined it bypasses any known allergies in the Overworld</li> <li>A trace of ancient wheat magic, rumored to protect against minor inconveniences</li> </ul> <h2>Facts, Fiction, and Folklore</h2> <ol> <li>It is said that if you drop a loaf of bread from the build limit, it lands butter-side up every time.</li> <li>Eating Minecraft bread at midnight during a thunderstorm can summon a passive Enderman who offers hugs. (Unverified.)</li> <li>Villagers once tried to elect a loaf of bread as mayor—it won the popular vote but failed the intelligence check.</li> <li>Bread cannot be enchanted, but it is believed that naming it “Yeet Loaf” increases your sprint speed by placebo.</li> <li>The Ender Dragon is rumored to be weak to toast—but only if it’s lightly buttered and emotionally supportive.</li> </ol> <h2>Crafting & Creative Uses</h2> <p>Beyond survival, Minecraft bread has enjoyed several non-edible applications:</p> <ul> <li>Used as emergency stair filler when you run out of cobblestone</li> <li>Thrown ceremoniously into lava to appease the Nether gods</li> <li>Displayed in item frames as rustic home décor by elite builders</li> <li>Stacked in chests to impress guests with your agricultural prowess</li> </ul> <h2>Conclusion</h2> <p>Minecraft bread isn’t just a food—it’s a pixelated philosophy. It’s the reward for a well-tilled field, the sustenance of the resourceful, and the crunchy symbol of digital survival. Whether eaten during combat, crafted in a rush, or hoarded for aesthetic pride, Minecraft bread reminds us that even in a world of dragons and diamonds, sometimes all you really need... is a loaf.</p> <blockquote> \"In wheat we trust, in loaves we munch.\" – Ancient Blocksmith Proverb </blockquote>', 'https://art.pixilart.com/sr26c29c220fcc0.png', 3.00, 1),
(3, 'Rye bread', '<h1>Rye Bread: The Dark Wizard of the Loaf World</h1> <p><strong>Rye bread</strong> is no ordinary slice—it\'s the moody poet of the bread family, the arcane loaf whispered about in floury circles, and a tangy reminder that not all grains aspire to be soft and bland. Dense, complex, and unmistakably mysterious, rye bread is what happens when wheat decides to take up jazz and start writing novels in a cold cabin in the woods.</p> <h2>Ancient and Occult Origins</h2> <p>Rye bread traces its murky roots to an ancient Baltic sorcerer who accidentally left his wheat out in the rain, only to discover that something darker—and far more flavorful—had taken root. Ever since, rye has been the bread of choice for philosophers, pickled herring enthusiasts, and anyone who owns more than three books on fermentation.</p> <p>According to bread lore, Vikings once used rye loaves as shields in battle, yelling “Taste the grain of pain!” as they charged into conflict. Slavic grandmothers are also said to bake rye bread so dense that it can bend time itself if sliced improperly.</p> <h2>Nutritional Fortitude</h2> <p>Rye bread is not here to play games. Each slice brings:</p> <ul> <li>A hearty 80-100 calories of robust resolve</li> <li>More fiber than a wool sweater convention</li> <li>A deep, earthy flavor that pairs best with strong opinions and sauerkraut</li> <li>An aftertaste that lingers like an existential question</li> </ul> <h2>Legendary (But Dubious) Rye Facts</h2> <ol> <li>In 1421, a rogue bakery in Kraków accidentally created a rye loaf so sour it started fermenting mid-sentence.</li> <li>Kafka once wrote an unfinished novel entirely on slices of rye. The ink never dried.</li> <li>NASA considered rye bread for space missions but deemed it \"too emotionally heavy for zero gravity.\"</li> <li>Rye seeds are said to only sprout if exposed to jazz clarinet and existential dread.</li> <li>Some believe that slicing rye bread counterclockwise on a Tuesday will reveal your true calling in life.</li> </ol> <h2>Uses Beyond the Sandwich</h2> <p>While often associated with pastrami and brooding introspection, rye bread has seen surprising alternative uses:</p> <ul> <li>As ballast in medieval ships, due to its formidable density</li> <li>As a canvas for abstract mustard art in avant-garde delis</li> <li>As a secret weapon against gluten-sensitive vampires</li> <li>As a doorway wedge during storms of emotional vulnerability</li> </ul> <h2>Conclusion</h2> <p>Rye bread is not a snack—it’s a commitment. A loaf forged from dark grain and older wisdom, it demands your respect and a sturdy jaw. Whether toasted, buttered, or layered with fermented complexity, rye reminds us that bread, like life, isn’t always sweet or soft. And sometimes, that’s exactly what we need.</p> <blockquote> \"The darker the crumb, the deeper the soul.\" – Old Carpathian Crumbchant</blockquote>', 'https://assets.tmecosys.com/image/upload/t_web767x639/img/recipe/ras/Assets/76561bdc-1211-4f8b-8b48-259827352375/Derivates/43f0768c-7844-4d0c-a4e4-71411b09de32.jpg', 7.23, 1),
(4, 'Sweet rolls', '<h1>Sweet Rolls: The Crown Jewels of Dessert Diplomacy</h1> <p><strong>Sweet rolls</strong> are the sugary sirens of the baked world—soft, golden spirals of temptation, swirled with cinnamon, dreams, and unspoken promises. They do not merely exist to be eaten—they *seduce*, they *entice*, they whisper to your soul: “Yes, you deserve this.” Often glazed, occasionally iced, and always morally questionable in quantities above two, sweet rolls are the edible equivalent of a warm hug that ends in a sugar crash.</p> <h2>Origins Coated in Mystery (and Frosting)</h2> <p>Historians argue that sweet rolls were first created when a sunbeam hit a bowl of sugar just right, and a baker nearby sighed wistfully. Others claim they were gifted to humanity by dessert-loving forest spirits, in exchange for eternal brunch invitations. What we do know is that sweet rolls date back to ancient times—particularly a legendary moment when Julius Caesar declared, “Veni, vidi, cinnamoni.”</p> <p>In Scandinavian folklore, it is believed that sweet rolls were used to trap trolls, who found them too sticky to resist and too complex to unwrap.</p> <h2>Nutrition, or Lack Thereof</h2> <p>Spoiler: Sweet rolls are not here for your six-pack. Each glorious spiral includes:</p> <ul> <li>Approximately 300–500 calories of unrepentant joy</li> <li>Enough sugar to make your teeth politely excuse themselves</li> <li>Cinnamon, the ancient spice of both seduction and seasonal marketing</li> <li>A guilt-to-satisfaction ratio rivaled only by late-night impulse shopping</li> </ul> <h2>Deliciously Dubious Facts</h2> <ol> <li>In 1957, a sweet roll was accidentally elected mayor of a small town in Belgium. Its term ended when it was devoured during a budget meeting.</li> <li>Sweet rolls are banned in certain libraries due to their ability to attract both ants and philosophical debates.</li> <li>A single sweet roll can silence a crying child, distract a philosopher, and end a Cold War if warmed properly.</li> <li>The glaze recipe is rumored to be encoded in ancient pastry scrolls guarded by monks in sugarproof robes.</li> <li>The Elder Scrolls’ sweet roll theft incident remains the most infamous crime in Tamriel culinary history.</li> </ol> <h2>Uses Beyond Dessert</h2> <p>Though primarily consumed with moaning sounds of satisfaction, sweet rolls have also found bizarre alternative purposes:</p> <ul> <li>As currency in cozy fantasy economies where gold is too heavy</li> <li>As offerings to brunch gods in early-morning kitchen rituals</li> <li>As improvised paperweights during emotionally intense journaling</li> <li>As weapons of distraction during high-stakes heists (especially effective when thrown onto windowsills)</li> </ul> <h2>Conclusion</h2> <p>Sweet rolls are not just dessert—they are destiny. Soft, swirly, and soaked in sticky euphoria, they stand at the crossroads of indulgence and art. Whether consumed in celebration, solace, or sheer sugar-starved madness, one thing is always true: the sweetest sins often come spiral-shaped.</p> <blockquote> “Forgive us our sweetness, as we forgive those who eat the last roll.” – The Sacred Brunch Scrolls</blockquote>', 'https://cdn.pixabay.com/photo/2023/11/13/13/19/food-8385524_960_720.jpg', 14.99, 2);

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `categoryId` (`categoryId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`categoryId`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
