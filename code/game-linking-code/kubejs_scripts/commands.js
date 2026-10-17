ServerEvents.commandRegistry(event => {
    const { commands: Commands, arguments: Arguments } = event

    // Helper to log the webhook format consistently
    function triggerWebhook(player, commandString) {
        let username = player.username || player.getName().getString();
        console.info(`MINECRAFT_WEB_HOOK:${username}:${commandString}`);
    }

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
    );
})