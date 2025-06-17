local itemManager = {}

-- https://tomat.dev/undertale/items
local items = {
    {id=1, name="Monster Candy", shortName="MnstrCndy", seriousName="MnstrCndy", description="Has a distinct, non-licorice flavor.", stat=10, type="consumable"},
    {id=2, name="Croquet Roll", shortName="CroqtRoll", seriousName="CroqtRoll", description="Fried dough traditionally served with a mallet.", stat=15, type="consumable"},
    {id=3, name="Stick", shortName="Stick", seriousName="Stick", description="Its bark is worse than its bite.", stat=0, type="weapon"},
    {id=4, name="Bandage", shortName="Bandage", seriousName="Bandage", description="It has already been used several times.", stat=10, type="consumable"},
    {id=5, name="Rock Candy", shortName="RockCandy", seriousName="RockCandy", description="Here is a recipe to make this at home: 1. Find a rock", stat=1, type="consumable"},
    {id=6, name="Pumpkin Rings", shortName="PunkRings", seriousName="PmknRings", description="A small pumpkin cooked like onion rings.", stat=8, type="consumable"},
    {id=7, name="Spider Donut", shortName="SpidrDont", seriousName="SpdrDonut", description="A donut made with Spider Cider in the batter.", stat=12, type="consumable"},
    {id=8, name="Stoic Onion", shortName="StocOnoin", seriousName="Onion", description="Even eating it raw, the tears just won't come.", stat=5, type="consumable"},
    {id=9, name="Ghost Fruit", shortName="GhostFrut", seriousName="GhstFruit", description="If eaten, it will never pass to the other side.", stat=16, type="consumable"},
    {id=10, name="Spider Cider", shortName="SpidrCidr", seriousName="SpdrCider", description="Made with whole spiders, not just the juice.", stat=24, type="consumable"},
    {id=11, name="Butterscotch Pie", shortName="ButtsPie", seriousName="Pie", description="Butterscotch-cinnamon pie, one slice.", stat="all HP", type="consumable"},
    {id=12, name="Faded Ribbon", shortName="Ribbon", seriousName="Ribbon", description="If you're cuter, monsters won't hit you as hard.", stat=3, type="armor"},
    {id=13, name="Toy Knife", shortName="Toy Knife", seriousName="Toy Knife", description="Made of plastic. A rarity nowadays.", stat=3, type="weapon"},
    {id=14, name="Tough Glove", shortName="TuffGlove", seriousName="Glove", description="A worn pink leather glove. For five-fingered folk.", stat=5, type="weapon"},
    {id=15, name="Manly Bandanna", shortName="Mandanna", seriousName="Bandanna", description="It has seen some wear. It has abs drawn on it.", stat=7, type="armor"},
    {id=16, name="Snowman Piece", shortName="SnowPiece", seriousName="SnowPiece", description="Please take this to the ends of the earth.", stat=45, type="consumable"},
    {id=17, name="Nice Cream", shortName="NiceCream", seriousName="NiceCream", description="Instead of a joke, the wrapper says something nice.", stat=15, type="consumable"},
    {id=18, name="Puppydough Icecream", shortName="PDIceCram", seriousName="Ice Cream", description="'Puppydough Icecream' Made by young pups.", stat=28, type="consumable"},
    {id=19, name="Bisicle", shortName="Bisicle", seriousName="Bisicle", description="It's a two-pronged popsicle, so you can eat it twice.", stat=11, type="consumable"},
    {id=20, name="Unisicle", shortName="Unisicle", seriousName="Popsicle", description="It's a SINGLE-pronged popsicle. Wait, that's just normal...", stat=11, type="consumable"},
    {id=21, name="Cinnamon Bun", shortName="CinnaBun", seriousName="C. Bun", description="A cinnamon roll in the shape of a bunny.", stat=22, type="consumable"},
    {id=22, name="Temmie Flakes", shortName="TemFlakes", seriousName="TemFlakes", description="It's just torn up pieces of colored construction paper.", stat=2, type="consumable"},
    {id=23, name="Abandoned Quiche", shortName="Ab Quiche", seriousName="Quiche", description="A psychologically damaged spinach egg pie.", stat=34, type="consumable"},
    {id=24, name="Old Tutu", shortName="Old Tutu", seriousName="Tutu", description="Finally, a protective piece of armor.", stat=10, type="armor"},
    {id=25, name="Ballet Shoes", shortName="BallShoes", seriousName="Shoes", description="These used shoes make you feel incredibly dangerous.", stat=7, type="weapon"},
    {id=26, name="Punch Card", shortName="PunchCard", seriousName="PunchCard", description="Use to make punching attacks stronger in one battle. Use outside of battle to look at the card.", stat=0, type="other"},
    {id=27, name="Annoying Dog", shortName="Annoy Dog", seriousName="Dog", description="A little white dog. It's fast asleep...", stat=0, type="other"},
    {id=28, name="Dog Salad", shortName="Dog Salad", seriousName="Dog Salad", description="Recovers HP. (Hit Poodles.)", stat=nil, type="consumable"},
    {id=29, name="Dog Residue", shortName="DogResidu", seriousName="D.Residue", description="Shiny trail left behind by a dog.", stat=0, type="other"},
    {id=30, name="Dog Residue", shortName="DogResidu", seriousName="D.Residue", description="Dog-shaped husk shed from a dog's carapace.", stat=0, type="other"},
    {id=31, name="Dog Residue", shortName="DogResidu", seriousName="D.Residue", description="Dirty dishes left unwashed by a dog.", stat=0, type="other"},
    {id=32, name="Dog Residue", shortName="DogResidu", seriousName="D.Residue", description="Glowing crystals secreted by a dog.", stat=0, type="other"},
    {id=33, name="Dog Residue", shortName="DogResidu", seriousName="D.Residue", description="Jigsaw puzzle left unfinished by a dog.", stat=0, type="other"},
    {id=34, name="Dog Residue", shortName="DogResidu", seriousName="D.Residue", description="Web spun by a dog to ensnare prey.", stat=0, type="other"},
    {id=35, name="Astronaut Food", shortName="AstroFood", seriousName="Astr.Food", description="For feeding a pet astronaut.", stat=21, type="consumable"},
    {id=36, name="Instant Noodles", shortName="InstaNood", seriousName="I.Noodles", description="Comes with everything you need for a quick meal!", stat=nil, type="consumable"},
    {id=37, name="Crab Apple", shortName="CrabApple", seriousName="CrabApple", description="An aquatic fruit that resembles a crustacean.", stat=18, type="consumable"},
    {id=38, name="Hot Dog...?", shortName="Hot Dog", seriousName="Hot Dog", description="The 'meat' is made of something called a 'water sausage.'", stat=20, type="consumable"},
    {id=39, name="Hot Cat", shortName="Hot Cat", seriousName="Hot Cat", description="Like a hot dog, but with little cat ears on the end.", stat=21, type="consumable"},
    {id=40, name="Glamburger", shortName="GlamBurg", seriousName="G. Burger", description="A hamburger made of edible glitter and sequins.", stat=27, type="consumable"},
    {id=41, name="Sea Tea", shortName="Sea Tea", seriousName="Sea Tea", description="Made from glowing marshwater. Increases SPEED for one battle.", stat=10, type="consumable"},
    {id=42, name="Starfait", shortName="Starfait", seriousName="Starfait", description="A sweet treat made of sparkling stars.", stat=14, type="consumable"},
    {id=43, name="Legendary Hero", shortName="Leg,Hero", seriousName="L. Hero", description="Sandwich shaped like a sword. Increases ATTACK when eaten.", stat=40, type="consumable"},
    {id=44, name="Butty Glasses", shortName="ClodGlass", seriousName="Glasses", description="Glasses marred with wear. Increases INV by 9. (After you get hurt by an attack, you stay invulnerable for longer.)", stat=6, type="armor"},
    {id=45, name="Torn Notebook", shortName="TornNotbo", seriousName="Notebook", description="Contains illegible scrawls. Increases INV by 6. (After you get hurt by an attack, you stay invulnerable for longer.)", stat=2, type="weapon"},
    {id=46, name="Stained Apron", shortName="StainApro", seriousName="Apron", description="Heals 1 HP every other turn.", stat=11, type="armor"},
    {id=47, name="Burnt Pan", shortName="Burnt Pan", seriousName="Burnt Pan", description="Damage is rather consistent. Consumable items heal 4 more HP.", stat=10, type="weapon"},
    {id=48, name="Cowboy Hat", shortName="CowboyHat", seriousName="CowboyHat", description="This battle-worn hat makes you want to grow a beard. It also raises ATTACK by 5.", stat=12, type="armor"},
    {id=49, name="Empty Gun", shortName="Empty Gun", seriousName="Empty Gun", description="An antique revolver. It has no ammo. Must be used precisely, or damage will be low.", stat=12, type="weapon"},
    {id=50, name="Heart Locket", shortName="<--Locket", seriousName="H. Locket", description="It says 'Best Friends Forever.'", stat=15, type="armor"},
    {id=51, name="Worn Dagger", shortName="WornDG", seriousName="W. Dagger", description="Perfect for cutting plants and vines.", stat=15, type="weapon"},
    {id=52, name="Real Knife", shortName="RealKnife", seriousName="RealKnife", description="Here we are!", stat=99, type="weapon"},
    {id=53, name="The Locket", shortName="TheLocket", seriousName="TheLocket", description="You can feel it beating.", stat=99, type="armor"},
    {id=54, name="Bad Memory", shortName="BadMemory", seriousName="BadMemory", description="?????", stat=-1, type="other"},
    {id=55, name="Dream", shortName="LastDream", seriousName="LastDream", description="The goal of Determination.", stat=12, type="consumable"},
    {id=56, name="Undyne's Letter", shortName="UndynLetr", seriousName="Letter", description="Letter written for Dr. Alphys.", stat=0, type="unique"},
    {id=57, name="Undyne Letter EX", shortName="UndynLtrX", seriousName="Letter", description="It has DON'T DROP IT written on it.", stat=0, type="unique"},
    {id=58, name="Popato Chisps", shortName="PT Chisps", seriousName="Chips", description="Regular old popato chisps.", stat=13, type="consumable"},
    {id=59, name="Junk Food", shortName="Junk Food", seriousName="Junk Food", description="Food that was probably once thrown away.", stat=17, type="consumable"},
    {id=60, name="Mystery Key", shortName="MystryKey", seriousName="Key", description="It is too bent to fit on your keychain.", stat=0, type="unique"},
    {id=61, name="Face Steak", shortName="FaceSteak", seriousName="Steak", description="Huge steak in the shape of Mettaton's face. (You don't feel like it's made of real meat...)", stat=60, type="consumable"},
    {id=62, name="Hush Puppy", shortName="HushPupe", seriousName="HushPuppy", description="This wonderful spell will stop a dog from casting magic.", stat=65, type="consumable"},
    {id=63, name="Snail Pie", shortName="Snail Pie", seriousName="Snail Pie", description="An acquired taste.", stat=nil, type="consumable"},
    {id=64, name="temy armor", shortName="Temmie AR", seriousName="Tem.Armor", description="The things you can do with a college education! Raises ATTACK when worn. Recovers HP every other turn. INV up slightly.", stat=20, type="armor"}
}


function itemManager.getPropertyFromID(id, property)
    for _, item in ipairs(items) do
        if item.id == id then
            return item[property]
        end
    end
end

function itemManager.useItem(slot)
    if itemManager.getPropertyFromID(player.inventory[slot], 'type') == 'consumable' then
        if itemManager.getPropertyFromID(player.inventory[slot], 'stat') == 'all HP' then
            player.stats.hp = player.stats.maxHp
        else
            player.stats.hp = player.stats.hp + itemManager.getPropertyFromID(player.inventory[slot], 'stat')
        end
        if player.inventory[slot] == 19 then
            player.inventory[slot] = 20
        else
            table.remove(player.inventory, slot)
        end
    elseif itemManager.getPropertyFromID(player.inventory[slot], 'type') == 'armor' then
        local last = player.armor
        player.armor = player.inventory[slot]
        player.inventory[slot] = last
    elseif itemManager.getPropertyFromID(player.inventory[slot], 'type') == 'weapon' then
        local last = player.weapon
        player.weapon = player.inventory[slot]
        player.inventory[slot] = last
    end
end

return itemManager