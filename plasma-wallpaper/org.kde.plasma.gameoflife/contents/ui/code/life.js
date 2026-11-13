.pragma library

var widthCells = 0;
var heightCells = 0;
var cellSize = 10;
var cells = [];
var nextCells = [];
var effects = [];
var visualLevels = [];
var cellPhases = [];
var lastAdvanceTime = 0;
var lastSpawnTime = 0;
var lastVisualTime = 0;
var fluidClock = 0;
var patterns = {
    single: [[0, 0]],
    glider: [[1, 0], [2, 1], [0, 2], [1, 2], [2, 2]],
    ship: [[1, 0], [4, 0], [0, 1], [0, 2], [4, 2], [0, 3], [1, 3], [2, 3], [3, 3]],
    blinker: [[0, 0], [1, 0], [2, 0]],
    toad: [[1, 0], [2, 0], [3, 0], [0, 1], [1, 1], [2, 1]],
    beacon: [[0, 0], [1, 0], [0, 1], [1, 1], [2, 2], [3, 2], [2, 3], [3, 3]],
    pulsar: [
        [2,0],[3,0],[4,0],[8,0],[9,0],[10,0], [0,2],[5,2],[7,2],[12,2],
        [0,3],[5,3],[7,3],[12,3], [0,4],[5,4],[7,4],[12,4],
        [2,5],[3,5],[4,5],[8,5],[9,5],[10,5], [2,7],[3,7],[4,7],[8,7],[9,7],[10,7],
        [0,8],[5,8],[7,8],[12,8], [0,9],[5,9],[7,9],[12,9],
        [0,10],[5,10],[7,10],[12,10], [2,12],[3,12],[4,12],[8,12],[9,12],[10,12]
    ]
};

function index(x, y) { return y * widthCells + x; }
function inside(x, y) { return x >= 0 && y >= 0 && x < widthCells && y < heightCells; }
function isEmpty() {
    for (var i = 0; i < cells.length; ++i) if (cells[i]) return false;
    return true;
}

function resize(width, height, size, density, preserve) {
    var newSize = Math.max(2, size);
    var newWidth = Math.max(1, Math.floor(width / newSize));
    var newHeight = Math.max(1, Math.floor(height / newSize));
    if (preserve && newSize === cellSize && newWidth === widthCells && newHeight === heightCells && cells.length)
        return false;
    cellSize = newSize;
    widthCells = newWidth;
    heightCells = newHeight;
    randomize(density);
    lastAdvanceTime = Date.now();
    lastSpawnTime = Date.now();
    return true;
}

function randomize(density) {
    var chance = Math.max(0, Math.min(100, density)) / 100;
    cells = new Array(widthCells * heightCells);
    nextCells = new Array(cells.length);
    effects = [];
    visualLevels = new Array(cells.length);
    cellPhases = new Array(cells.length);
    for (var i = 0; i < cells.length; ++i) {
        cells[i] = Math.random() < chance;
        visualLevels[i] = cells[i] ? 1 : 0;
        cellPhases[i] = Math.random() * Math.PI * 2;
    }
    lastVisualTime = Date.now();
}

function clear() {
    if (!cells.length) cells = new Array(widthCells * heightCells);
    nextCells = new Array(cells.length);
    effects = [];
    for (var i = 0; i < cells.length; ++i) cells[i] = false;
}

function neighbourCount(x, y) {
    var count = 0;
    for (var oy = -1; oy <= 1; ++oy) {
        for (var ox = -1; ox <= 1; ++ox) {
            if (ox === 0 && oy === 0) continue;
            var nx = (x + ox + widthCells) % widthCells;
            var ny = (y + oy + heightCells) % heightCells;
            if (cells[index(nx, ny)]) ++count;
        }
    }
    return count;
}

function advance() {
    var any = false;
    for (var y = 0; y < heightCells; ++y) {
        for (var x = 0; x < widthCells; ++x) {
            var i = index(x, y);
            var neighbours = neighbourCount(x, y);
            nextCells[i] = neighbours === 3 || (cells[i] && neighbours === 2);
            if (nextCells[i] !== cells[i])
                effects.push({ x: x, y: y, age: 0, kind: nextCells[i] ? "birth" : "death" });
            any = any || nextCells[i];
        }
    }
    var swap = cells; cells = nextCells; nextCells = swap;
    return any;
}

// WallpaperItem is instantiated once per monitor.  The JS library is shared,
// so guard mutations here as well as in QML to prevent two near-simultaneous
// screen timers from advancing the same field twice.
function advanceIfDue(interval) {
    var now = Date.now();
    if (now - lastAdvanceTime < Math.max(1, interval) * 0.9) return -1;
    lastAdvanceTime = now;
    return advance() ? 1 : 0;
}

function setCell(x, y, alive, animate) {
    if (!inside(x, y)) return;
    var i = index(x, y);
    var changed = cells[i] !== alive;
    cells[i] = alive;
    if (visualLevels[i] === undefined) visualLevels[i] = alive ? 1 : 0;
    if (cellPhases[i] === undefined) cellPhases[i] = Math.random() * Math.PI * 2;
    if (changed && animate) effects.push({ x: x, y: y, age: 0, kind: alive ? "birth" : "death" });
}

function addPattern(name, centerX, centerY, animate) {
    var shape = patterns[name] || patterns.single;
    var rotation = Math.floor(Math.random() * 4);
    for (var i = 0; i < shape.length; ++i) {
        var px = shape[i][0], py = shape[i][1], rx = px, ry = py;
        if (rotation === 1) { rx = -py; ry = px; }
        else if (rotation === 2) { rx = -px; ry = -py; }
        else if (rotation === 3) { rx = py; ry = -px; }
        setCell(centerX + rx, centerY + ry, true, animate);
    }
}

function addCloud(centerX, centerY, size, density, animate) {
    var radius = Math.max(1, Math.floor(size / 2));
    var chance = Math.max(1, Math.min(100, density)) / 100;
    for (var y = -radius; y <= radius; ++y)
        for (var x = -radius; x <= radius; ++x)
            if (Math.random() < chance) setCell(centerX + x, centerY + y, true, animate);
}

function randomPattern(options) {
    var choices = [];
    if (options.singles) choices.push("single");
    if (options.clouds) choices.push("cloud");
    if (options.gliders) choices.push("glider");
    if (options.ships) choices.push("ship");
    if (options.oscillators) choices.push("blinker", "toad", "beacon", "pulsar");
    return choices.length ? choices[Math.floor(Math.random() * choices.length)] : "single";
}

function spawnMixed(count, options) {
    for (var i = 0; i < count; ++i) {
        var x = Math.floor(Math.random() * widthCells);
        var y = Math.floor(Math.random() * heightCells);
        var name = randomPattern(options);
        if (name === "cloud") addCloud(x, y, options.cloudSize, options.cloudDensity, true);
        else addPattern(name, x, y, true);
    }
}

function spawnMixedIfDue(count, options, interval) {
    var now = Date.now();
    if (now - lastSpawnTime < Math.max(1, interval) * 0.9) return false;
    lastSpawnTime = now;
    spawnMixed(count, options);
    return true;
}

function addAtPixel(px, py, patternIndex, alive, options) {
    var x = Math.floor(px / cellSize), y = Math.floor(py / cellSize);
    if (!alive) { setCell(x, y, false, true); return; }
    var names = ["single", "glider", "ship", "blinker", "toad", "beacon", "pulsar", "cloud"];
    var name = names[Math.max(0, Math.min(names.length - 1, patternIndex))];
    if (name === "cloud") addCloud(x, y, options.cloudSize, options.cloudDensity, true);
    else addPattern(name, x, y, true);
}

function updateEffects(deltaMs, birthDuration, deathDuration) {
    for (var i = effects.length - 1; i >= 0; --i) {
        effects[i].age += deltaMs;
        var duration = effects[i].kind === "death" ? deathDuration : birthDuration;
        if (effects[i].age >= duration) effects.splice(i, 1);
    }
}

function updateVisualsIfDue(frameInterval, transitionDuration, fluidSpeed, animateSmoothly) {
    var now = Date.now();
    if (now - lastVisualTime < Math.max(8, frameInterval) * 0.7) return false;
    var delta = Math.min(100, Math.max(1, now - lastVisualTime));
    lastVisualTime = now;
    fluidClock += delta * (0.0004 + fluidSpeed * 0.000025);
    var step = animateSmoothly ? Math.min(1, delta / Math.max(50, transitionDuration)) : 1;
    for (var i = 0; i < cells.length; ++i) {
        var target = cells[i] ? 1 : 0;
        var current = visualLevels[i] || 0;
        // Move by a fixed fraction of the full range so birth and death both
        // take exactly transitionDuration instead of death collapsing early.
        if (target > current) visualLevels[i] = Math.min(target, current + step);
        else if (target < current) visualLevels[i] = Math.max(target, current - step);
        if (Math.abs(visualLevels[i] - target) < 0.01) visualLevels[i] = target;
    }
    return true;
}

function snapVisuals() {
    for (var i = 0; i < cells.length; ++i) visualLevels[i] = cells[i] ? 1 : 0;
}

function roundedRect(ctx, x, y, width, height, radius) {
    radius = Math.max(0, Math.min(radius, Math.min(width, height) / 2));
    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + width - radius, y);
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
    ctx.lineTo(x + width, y + height - radius);
    ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
    ctx.lineTo(x + radius, y + height);
    ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
    ctx.lineTo(x, y + radius);
    ctx.quadraticCurveTo(x, y, x + radius, y);
    ctx.closePath();
}

function fluidRadius(i, level, baseRadius, strength) {
    var wobble = Math.sin(fluidClock + cellPhases[i]) * 0.12 * strength;
    var secondWave = Math.sin(fluidClock * 1.73 + cellPhases[i] * 2.1) * 0.055 * strength;
    return Math.max(0, baseRadius * level * (1 + wobble + secondWave));
}

function paint(ctx, width, height, options, offsetX, offsetY) {
    ctx.fillStyle = options.backgroundColor;
    ctx.fillRect(0, 0, width, height);
    offsetX = offsetX || 0;
    offsetY = offsetY || 0;
    var firstX = Math.max(0, Math.floor(offsetX / cellSize));
    var firstY = Math.max(0, Math.floor(offsetY / cellSize));
    var lastX = Math.min(widthCells, Math.ceil((offsetX + width) / cellSize));
    var lastY = Math.min(heightCells, Math.ceil((offsetY + height) / cellSize));
    var gap = cellSize * Math.max(0, Math.min(45, options.cellGap)) / 100;
    var baseSize = Math.max(0.5, cellSize - gap * 2);
    var shape = options.cellShape || 0;
    var strength = Math.max(0, Math.min(100, options.fluidStrength)) / 100;
    ctx.fillStyle = options.color;

    // Metaball-like bridges make neighboring droplets merge into larger blobs.
    if (shape === 3) {
        ctx.strokeStyle = options.color;
        ctx.lineCap = "round";
        var neighbourOffsets = [
            [1, 0], [0, 1], [1, 1], [-1, 1],
            [2, 0], [0, 2], [2, 1], [1, 2], [-1, 2], [-2, 1]
        ];
        for (var by = firstY; by < lastY; ++by) {
            for (var bx = firstX; bx < lastX; ++bx) {
                var bi = index(bx, by), bl = visualLevels[bi] || 0;
                if (bl < 0.03) continue;
                var bcx = (bx + 0.5) * cellSize - offsetX;
                var bcy = (by + 0.5) * cellSize - offsetY;
                for (var n = 0; n < neighbourOffsets.length; ++n) {
                    var nx = bx + neighbourOffsets[n][0], ny = by + neighbourOffsets[n][1];
                    if (!inside(nx, ny)) continue;
                    var distance = Math.sqrt(neighbourOffsets[n][0] * neighbourOffsets[n][0]
                                             + neighbourOffsets[n][1] * neighbourOffsets[n][1]);
                    // At higher fluidity, liquid can stretch across one empty
                    // grid position and pull nearby droplets into the same mass.
                    if (distance > 1.5 && strength < 0.55) continue;
                    var neighbourLevel = visualLevels[index(nx, ny)] || 0;
                    if (neighbourLevel > 0.03) {
                        var bridgeLevel = Math.min(bl, neighbourLevel);
                        var distanceFactor = distance > 1.5
                                ? (0.32 + strength * 0.38) : 1;
                        ctx.globalAlpha = Math.min(1, bridgeLevel * (1.4 + strength * 0.8));
                        // Nearly droplet-wide bridges create a continuous mass
                        // rather than circles joined by thin grid lines.
                        ctx.lineWidth = cellSize * (1.15 + strength * 0.85)
                                * bridgeLevel * distanceFactor;
                        ctx.beginPath();
                        ctx.moveTo(bcx, bcy);
                        ctx.lineTo(bcx + neighbourOffsets[n][0] * cellSize,
                                   bcy + neighbourOffsets[n][1] * cellSize);
                        ctx.stroke();
                    }
                }
            }
        }
        ctx.globalAlpha = 1;
    }

    for (var y = firstY; y < lastY; ++y) {
        for (var x = firstX; x < lastX; ++x) {
            var i = index(x, y), level = visualLevels[i] || 0;
            if (level < 0.01) continue;
            // Smoothstep keeps the beginning and end of both directions soft.
            level = level * level * (3 - 2 * level);
            var cx = (x + 0.5) * cellSize - offsetX;
            var cy = (y + 0.5) * cellSize - offsetY;
            var scale = shape === 3 ? 1 : level;
            var drawSize = baseSize * scale;
            ctx.globalAlpha = shape === 3 ? Math.min(1, level * 1.4) : level;
            if (shape === 0) {
                ctx.fillRect(cx - drawSize / 2, cy - drawSize / 2, drawSize, drawSize);
            } else if (shape === 1) {
                var radius = drawSize * Math.max(0, Math.min(100, options.cornerRadius)) / 200;
                roundedRect(ctx, cx - drawSize / 2, cy - drawSize / 2, drawSize, drawSize, radius);
                ctx.fill();
            } else {
                var circleRadius = drawSize / 2;
                if (shape === 3) circleRadius = fluidRadius(i, level, cellSize * (0.68 + strength * 0.22), strength);
                ctx.beginPath(); ctx.arc(cx, cy, circleRadius, 0, Math.PI * 2); ctx.fill();
                if (shape === 3 && strength > 0.15 && level > 0.05) {
                    // Two moving lobes break the perfect-circle silhouette and
                    // make isolated cells read as deforming droplets.
                    var lobeOffset = circleRadius * (0.18 + strength * 0.16);
                    var phase = fluidClock * 0.8 + cellPhases[i];
                    ctx.beginPath();
                    ctx.arc(cx + Math.cos(phase) * lobeOffset,
                            cy + Math.sin(phase) * lobeOffset,
                            circleRadius * (0.58 + strength * 0.12), 0, Math.PI * 2);
                    ctx.fill();
                    ctx.beginPath();
                    ctx.arc(cx - Math.cos(phase * 1.37) * lobeOffset * 0.75,
                            cy - Math.sin(phase * 1.37) * lobeOffset * 0.75,
                            circleRadius * 0.46, 0, Math.PI * 2);
                    ctx.fill();
                }
            }
        }
    }
    ctx.globalAlpha = 1;

    if ((options.birthAnimationType === 0 && options.deathAnimationType === 0)
            || (options.birthDuration <= 0 && options.deathDuration <= 0)) return;
    for (var i = 0; i < effects.length; ++i) {
        var effect = effects[i];
        var dying = effect.kind === "death";
        var effectType = dying ? options.deathAnimationType : options.birthAnimationType;
        var duration = dying ? options.deathDuration : options.birthDuration;
        var strength = (dying ? options.deathIntensity : options.birthIntensity) / 100;
        var effectColor = dying ? options.deathEffectColor : options.birthEffectColor;
        if (effectType === 0 || duration <= 0) continue;
        var progress = Math.min(1, effect.age / duration);
        var cx = (effect.x + 0.5) * cellSize - offsetX, cy = (effect.y + 0.5) * cellSize - offsetY;
        if (cx < -cellSize * 5 || cy < -cellSize * 5 || cx > width + cellSize * 5 || cy > height + cellSize * 5) continue;
        ctx.save();
        ctx.fillStyle = effectColor;
        ctx.strokeStyle = effectColor;
        if (effectType === 1) {
            ctx.globalAlpha = (1 - progress) * strength;
            ctx.fillRect(effect.x * cellSize - offsetX, effect.y * cellSize - offsetY, cellSize, cellSize);
        } else if (effectType === 2) {
            ctx.globalAlpha = (1 - progress) * strength;
            var flash = cellSize * (1 + strength * 2 * (1 - progress));
            ctx.fillRect(cx - flash / 2, cy - flash / 2, flash, flash);
        } else if (effectType === 3) {
            ctx.globalAlpha = (1 - progress) * strength;
            var pulse = cellSize * (1 + Math.sin(progress * Math.PI * 4) * strength * 0.7);
            ctx.fillRect(cx - pulse / 2, cy - pulse / 2, pulse, pulse);
        } else if (effectType === 4) {
            ctx.globalAlpha = (1 - progress) * strength;
            ctx.lineWidth = Math.max(1, cellSize * 0.18);
            ctx.beginPath(); ctx.arc(cx, cy, cellSize * (0.5 + progress * 4 * strength), 0, Math.PI * 2); ctx.stroke();
        } else if (effectType === 5) {
            ctx.globalAlpha = (1 - progress) * strength;
            ctx.fillRect(effect.x * cellSize - offsetX, effect.y * cellSize - offsetY, cellSize, cellSize);
        } else if (effectType === 6) {
            // Pop: overshoot rapidly, then collapse into the cell centre.
            ctx.globalAlpha = (1 - progress) * strength;
            var popCurve = dying ? (1 - progress) : Math.sin(progress * Math.PI);
            var popSize = cellSize * (0.3 + popCurve * 2.1);
            ctx.beginPath(); ctx.arc(cx, cy, popSize, 0, Math.PI * 2); ctx.fill();
        } else if (effectType === 7) {
            // Double ripple.
            ctx.globalAlpha = (1 - progress) * strength;
            ctx.lineWidth = Math.max(1, cellSize * (0.1 + strength * 0.18));
            ctx.beginPath(); ctx.arc(cx, cy, cellSize * (0.5 + progress * 3.5), 0, Math.PI * 2); ctx.stroke();
            if (progress > 0.22) {
                ctx.beginPath(); ctx.arc(cx, cy, cellSize * (0.5 + (progress - 0.22) * 3.5), 0, Math.PI * 2); ctx.stroke();
            }
        } else if (effectType === 8) {
            // Four sparks fly away from the cell.
            ctx.globalAlpha = (1 - progress) * strength;
            ctx.lineWidth = Math.max(1, cellSize * 0.16);
            for (var spark = 0; spark < 4; ++spark) {
                var angle = spark * Math.PI / 2 + cellPhases[index(effect.x, effect.y)];
                var inner = cellSize * (0.3 + progress * 1.5);
                var outer = inner + cellSize * (0.35 + strength * 0.4);
                ctx.beginPath();
                ctx.moveTo(cx + Math.cos(angle) * inner, cy + Math.sin(angle) * inner);
                ctx.lineTo(cx + Math.cos(angle) * outer, cy + Math.sin(angle) * outer);
                ctx.stroke();
            }
        } else if (effectType === 9) {
            // Dissolve into deterministic particles.
            ctx.globalAlpha = (1 - progress) * strength;
            for (var particle = 0; particle < 7; ++particle) {
                var seed = cellPhases[index(effect.x, effect.y)] + particle * 2.399;
                var distance = cellSize * progress * (0.8 + (particle % 3) * 0.55);
                var particleSize = Math.max(1, cellSize * 0.18 * (1 - progress));
                ctx.fillRect(cx + Math.cos(seed) * distance - particleSize / 2,
                             cy + Math.sin(seed) * distance - particleSize / 2,
                             particleSize, particleSize);
            }
        }
        ctx.restore();
    }
}
