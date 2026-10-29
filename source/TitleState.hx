package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;

class TitleState extends MusicBeatState
{
    public static var initialized:Bool = false;
    public static var closedState:Bool = false;
    public static var updateVersion:String = '';

    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
    public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
    public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    var logo:FlxSprite;
    var startButton:FlxSprite;
    var glow:FlxSprite;
    var spikesTop:FlxSprite;
    var spikesBottom:FlxSprite;
    var entered:Bool = false;
    var confirmSound:FlxSound;
    var pulseTime:Float = 0;

    override public function create():Void
    {
        #if android
        FlxG.android.preventDefaultKeys = [BACK];
        #end

        // Keep the engine's normal startup: mods, preferences, saves and scores.
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();
        #if LUA_ALLOWED
        Paths.pushGlobalMods();
        #end
        WeekData.loadTheFirstEnabledMod();
        PlayerSettings.init();

        FlxG.save.bind('funkin', CoolUtil.getSavePath());
        ClientPrefs.loadPrefs();
        Highscore.load();

        super.create();

        if (FlxG.sound.music == null)
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7, true);

        // Background and depth layers.
        var bg = makeSprite('menus/title/bg');
        fitToScreen(bg);
        bg.scrollFactor.set(0, 0);
        add(bg);

        var pillar3 = makeSprite('menus/title/pillar-3');
        pillar3.scrollFactor.set(0.25, 0.25);
        add(pillar3);

        var pillar2 = makeSprite('menus/title/pillar-2');
        pillar2.scrollFactor.set(0.4, 0.4);
        add(pillar2);

        var pillar1 = makeSprite('menus/title/pillar-1');
        pillar1.scrollFactor.set(0.6, 0.6);
        add(pillar1);

        var pillarMid = makeSprite('menus/title/pillar-mid');
        add(pillarMid);

        var pillarEdge = makeSprite('menus/title/pillar-edge');
        add(pillarEdge);

        // Use ordinary sprites rather than FlxBackdrop for better compatibility.
        spikesTop = makeSprite('menus/title/spikes');
        fitToScreenWidth(spikesTop);
        spikesTop.x = (FlxG.width - spikesTop.width) * 0.5;
        spikesTop.y = -spikesTop.height + 18;
        add(spikesTop);

        spikesBottom = new FlxSprite();
        spikesBottom.loadGraphic(Paths.image('menus/title/spikes'));
        fitToScreenWidth(spikesBottom);
        spikesBottom.x = (FlxG.width - spikesBottom.width) * 0.5;
        spikesBottom.y = FlxG.height - 18;
        spikesBottom.flipY = true;
        add(spikesBottom);

        logo = makeSprite('menus/title/logo');
        fitToScreenWidth(logo);
        logo.x = (FlxG.width - logo.width) * 0.5;
        logo.y = FlxG.height * 0.16;
        add(logo);

        glow = new FlxSprite();
        glow.loadGraphic(Paths.image('menus/title/start-glow'));
        fitToScreenWidth(glow);
        glow.blend = BlendMode.ADD;
        glow.color = 0xFFFF164F;
        glow.x = (FlxG.width - glow.width) * 0.5;
        glow.y = FlxG.height - glow.height * 0.72;
        add(glow);

        startButton = new FlxSprite();
        startButton.loadGraphic(Paths.image('menus/title/start'));
        fitToScreenWidth(startButton);
        startButton.x = (FlxG.width - startButton.width) * 0.5;
        startButton.y = glow.y + glow.height * 0.35;
        add(startButton);

        var vignette = makeSprite('menus/title/vignette');
        fitToScreen(vignette);
        vignette.scrollFactor.set(0, 0);
        add(vignette);

        for (sprite in [bg, pillar3, pillar2, pillar1, pillarMid, pillarEdge,
                        spikesTop, spikesBottom, logo, glow, startButton, vignette])
            sprite.antialiasing = ClientPrefs.globalAntialiasing;

        spikesTop.scrollFactor.set(0, 0);
        spikesBottom.scrollFactor.set(0, 0);
        spikesTop.alpha = 0.9;
        spikesBottom.alpha = 0.9;

        FlxG.camera.zoom = 1;
        initialized = true;
    }

    function makeSprite(key:String):FlxSprite
    {
        var spr = new FlxSprite();
        spr.loadGraphic(Paths.image(key));
        spr.screenCenter();
        return spr;
    }

    function fitToScreen(sprite:FlxSprite):Void
    {
        sprite.setGraphicSize(FlxG.width, FlxG.height);
        sprite.updateHitbox();
    }

    function fitToScreenWidth(sprite:FlxSprite):Void
    {
        if (sprite.width > FlxG.width)
        {
            sprite.setGraphicSize(FlxG.width);
            sprite.updateHitbox();
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        pulseTime += elapsed;

        if (logo != null && !entered)
        {
            logo.y = FlxG.height * 0.16 + Math.sin(pulseTime * 1.2) * 7;
            glow.alpha = 0.72 + (Math.sin(pulseTime * 3.0) + 1) * 0.14;
            startButton.alpha = 0.82 + (Math.sin(pulseTime * 3.0) + 1) * 0.09;
        }

        var pressed:Bool = controls.ACCEPT || FlxG.keys.justPressed.ENTER;
        #if mobile
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
                pressed = true;
        }
        #end
        if (FlxG.mouse.justPressed)
            pressed = true;

        if (!entered && pressed)
        {
            entered = true;
            if (glow != null) glow.color = FlxColor.WHITE;
            if (startButton != null) startButton.alpha = 1;

            confirmSound = FlxG.sound.play(Paths.sound('menu/confirm'));
            FlxG.camera.fade(FlxColor.BLACK, 0.55, false, function()
            {
                FlxG.switchState(new MainMenuState());
            });
        }
    }
}
