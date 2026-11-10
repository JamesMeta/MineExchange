PlayerEvents.loggedIn(event => {
    let player = event.player;
    let username = player.username || player.getName().getString();

    // Safely evaluate game mode string
    let gm = "survival";
    if (player.isCreative()) {
        gm = "creative";
    } else if (player.isSpectator()) {
        gm = "spectator";
    } else if (player.isAdventure()) {
        gm = "adventure";
    }

    let playerPayload = {
        username: username,
        uuid: player.uuid ? player.uuid.toString() : "",
        message: "!player_join",
        x: Math.round(player.x * 100) / 100,
        y: Math.round(player.y * 100) / 100,
        z: Math.round(player.z * 100) / 100,
        dimension: player.level.dimension.toString(),
        health: player.health,
        maxHealth: player.maxHealth,
        foodLevel: player.foodLevel,
        mainHand: player.mainHandItem.id,
        gameMode: gm
    };

    // Print the hook to the console so your Python watcher grabs it instantly
    console.info("MINECRAFT_WEB_HOOK:" + JSON.stringify(playerPayload));
});


ServerEvents.commandRegistry(event => {
    const { commands: Commands, arguments: Arguments } = event

    // Helper to log the webhook format consistently
    function triggerWebhook(player, commandString) {
        let username = player.username || player.getName().getString();

        let playerPayload = {
            username: username,
            uuid: player.uuid ? player.uuid.toString() : "",
            message: commandString,
            x: Math.round(player.x * 100) / 100,       // Rounded to 2 decimal places
            y: Math.round(player.y * 100) / 100,
            z: Math.round(player.z * 100) / 100,
            dimension: player.level.dimension.toString(),
            health: player.health,
            maxHealth: player.maxHealth,
            foodLevel: player.foodLevel,
            mainHand: player.getMainHandItem().getId(),
        };

        console.info("MINECRAFT_WEB_HOOK:" + JSON.stringify(playerPayload));
    }


    // 0. /mypos
    event.register(
        Commands.literal('home')

            .then(Commands.literal('go')
                .executes(ctx => {
                    let player = ctx.source.player;
                    triggerWebhook(player, "!home go");
                    return 1;
                })
            )
            .then(Commands.literal('set')
                .executes(ctx => {
                    let player = ctx.source.player;
                    triggerWebhook(player, "!home set");
                    return 1;
                })
            )
    );

    // 1. /op self
    event.register(
        Commands.literal('opp')
            .then(Commands.literal('self')
                .executes(ctx => {
                    triggerWebhook(ctx.source.player, "!op self");
                    return 1;
                })
            )
    );

    // 2. /deop self
    event.register(
        Commands.literal('deopp')
            .then(Commands.literal('self')
                .executes(ctx => {
                    triggerWebhook(ctx.source.player, "!deop self");
                    return 1;
                })
            )
    );

    // 3. /spawn
    event.register(
        Commands.literal('spawn')
            .executes(ctx => {
                triggerWebhook(ctx.source.player, "!spawn");
                return 1;
            })
    );

    // 4. /withdraw <amount> (with tab-autocomplete presets)
    event.register(
        Commands.literal('withdraw')
            .then(
                Commands.argument('amount', Arguments.INTEGER.create(event))
                    .suggests((ctx, builder) => {
                        const presets = [100, 500, 1000, 5000, 10000];
                        presets.forEach(n => builder.suggest(n));
                        return builder.buildFuture();
                    })
                    .executes(ctx => {
                        let amount = Arguments.INTEGER.getResult(ctx, 'amount');
                        triggerWebhook(ctx.source.player, `!withdraw ${amount}`);
                        return 1;
                    })
            )
    );

    // 5. /inventory claim <item_tag> [amount]
    event.register(
        Commands.literal('inventory')
            .then(Commands.literal('claim')
                .then(Commands.argument('item', Arguments.RESOURCE_LOCATION.create(event))
                    .suggests((ctx, builder) => {
                        // Grab what the player has typed so far and convert to lowercase
                        let input = builder.getRemaining().toLowerCase();
                        
                        // Loop through items and only suggest ones that match the input
                        Item.getList().forEach(item => {
                            let id = item.getId();
                            if (id.toLowerCase().includes(input)) {
                                builder.suggest(id);
                            }
                        });
                        
                        return builder.buildFuture();
                    })
                    .executes(ctx => {
                        let item = Arguments.RESOURCE_LOCATION.getResult(ctx, 'item');
                        triggerWebhook(ctx.source.player, `!inventory claim ${item}`);
                        return 1;
                    })
                    .then(Commands.argument('amount', Arguments.INTEGER.create(event))
                        .executes(ctx => {
                            let item = Arguments.RESOURCE_LOCATION.getResult(ctx, 'item');
                            let amount = Arguments.INTEGER.getResult(ctx, 'amount');
                            triggerWebhook(ctx.source.player, `!inventory claim ${item} ${amount}`);
                            return 1;
                        })
                    )
                )
            )
            .then(Commands.literal('list')
                .executes(ctx => {
                    triggerWebhook(ctx.source.player, "!inventory list");
                    return 1;
                })
            )
            .then(Commands.literal('deposit')
                .then(Commands.argument('item', Arguments.RESOURCE_LOCATION.create(event))
                    .suggests((ctx, builder) => {
                        // Grab what the player has typed so far and convert to lowercase
                        let input = builder.getRemaining().toLowerCase();
                        
                        // Loop through items and only suggest ones that match the input
                        Item.getList().forEach(item => {
                            let id = item.getId();
                            if (id.toLowerCase().includes(input)) {
                                builder.suggest(id);
                            }
                        });
                        
                        return builder.buildFuture();
                    })
                    .executes(ctx => {
                        let item = Arguments.RESOURCE_LOCATION.getResult(ctx, 'item');
                        let amount = 1; // Default amount if not specified
                        let player = ctx.source.player;
                        let username = player.username || player.getName().getString();
                        let server = ctx.source.getServer();

                        
                        let amount_in_inventory = 0;

                        player.inventory.allItems.forEach(inventory_item => {
                            let itemId = inventory_item.id;
                            let count = inventory_item.count;
                            
                            if (itemId === item) {
                                amount_in_inventory += count;
                            }
                        });

                        if (amount_in_inventory >= amount) {

                            server.runCommand(`clear ${username} ${item} ${amount}`);

                            triggerWebhook(ctx.source.player, `!inventory deposit ${item} 1`);
                            return 1;
                        }
                        else{
                            triggerWebhook(ctx.source.player, `!inventory deposit ${item} -99`);
                            return 1;
                        }

                        
                    })
                    .then(Commands.argument('amount', Arguments.INTEGER.create(event))
                        .executes(ctx => {
                            let player = ctx.source.player;
                            let username = player.username || player.getName().getString();
                            let item = Arguments.RESOURCE_LOCATION.getResult(ctx, 'item');
                            let amount = Arguments.INTEGER.getResult(ctx, 'amount');
                            let amount_in_inventory = 0;
                            let server = ctx.source.getServer();

                        player.inventory.allItems.forEach(inventory_item => {
                            let itemId = inventory_item.id;
                            let count = inventory_item.count;
                            
                            if (itemId === item) {
                                amount_in_inventory += count;
                            }
                        });

                        if (amount_in_inventory >= amount) {

                            server.runCommand(`clear ${username} ${item} ${amount}`);

                            triggerWebhook(ctx.source.player, `!inventory deposit ${item} ${amount}`);
                            return 1;
                        }
                        else{
                            triggerWebhook(ctx.source.player, `!inventory deposit ${item} -99`);
                            return 1;
                        }
                        })
                    )
                )
            )
    );
    
    event.register(
        Commands.literal('me')
            .executes(ctx => {
                let player = ctx.source.player;
                let username = player.username || player.getName().getString();

                // Construct a raw JSON text component with a click event
                let jsonComponent = JSON.stringify({
                    text: "[ Click Here to Open MineExchange ]",
                    color: "#55FFFF",
                    bold: true,
                    clickEvent: {
                        action: "open_url",
                        value: "https://mineexchange.vercel.app/#/home" // Replace with your actual URL
                    },
                    hoverEvent: {
                        action: "show_text",
                        contents: "Click to open in your browser!"
                    }
                });

                // Execute a tellraw command targeting only this specific player
                let server = ctx.source.getServer();
                server.runCommand(`tellraw ${username} ${jsonComponent}`);

                return 1;
            })
    );
})