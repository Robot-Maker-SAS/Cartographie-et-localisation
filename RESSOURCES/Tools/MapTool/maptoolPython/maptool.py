"""
Cartographie & Lidar - Python/Pygame
© QUILLES Jonathan (2026)

Installation requise:
pip install pygame
"""

import pygame
import math
import random
import sys
from pathlib import Path

# Initialisation Pygame
pygame.init()

# Constantes
PANEL_WIDTH = 320
WINDOW_WIDTH = 1200
WINDOW_HEIGHT = 800
FPS = 60

# Couleurs
COLOR_BG = (15, 23, 42)
COLOR_PANEL = (17, 24, 39)
COLOR_WHITE = (255, 255, 255)
COLOR_GRID = (209, 213, 219)
COLOR_BLACK = (0, 0, 0)
COLOR_RED = (239, 68, 68)
COLOR_ORANGE = (245, 158, 11)
COLOR_CYAN = (6, 182, 212)
COLOR_CYAN_ALPHA = (6, 182, 212, 60)
COLOR_BLUE = (56, 189, 248)
COLOR_GREEN = (34, 197, 94)
COLOR_TEXT = (229, 231, 235)
COLOR_MUTED = (148, 163, 184)

# État global
state = {
    'scene_w': 2.0,
    'scene_h': 3.0,
    'cell_size': 0.10,
    'num_rays': 100,
    'add_borders': True,
    'show_scan': True,
    'delete_mode': False,
    'segments': [],
    'grid_occ': [],
    'grid_nx': 0,
    'grid_ny': 0,
    'robot': {'x': 0.5, 'y': 0.5, 'th_deg': 0},
    'view_scale': 220,
    'view_ox': 30,
    'view_oy': 30,
    'noise_angle': 0.0,
    'noise_dist': 0.0,
    'dragging': False,
    'drag_from': None,
    'dragging_robot': False,
    'active_field': None,
    'field_values': {}
}

class Segment:
    def __init__(self, x1, y1, x2, y2):
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2

class UIField:
    def __init__(self, x, y, w, h, label, key, default_value):
        self.rect = pygame.Rect(x, y, w, h)
        self.label = label
        self.key = key
        self.value = str(default_value)
        self.active = False
        
    def draw(self, screen, font):
        # Label
        label_font = pygame.font.Font(None, 18)
        label_surf = label_font.render(self.label, True, COLOR_MUTED)
        screen.blit(label_surf, (self.rect.x, self.rect.y - 16))
        
        # Champ
        color = (80, 80, 100) if self.active else (40, 40, 50)
        pygame.draw.rect(screen, color, self.rect, border_radius=6)
        pygame.draw.rect(screen, (55, 65, 81), self.rect, 1, border_radius=6)
        
        # Texte
        text_font = pygame.font.Font(None, 20)
        text_surf = text_font.render(self.value, True, COLOR_TEXT)
        screen.blit(text_surf, (self.rect.x + 8, self.rect.y + 7))
    
    def handle_event(self, event):
        if event.type == pygame.MOUSEBUTTONDOWN:
            self.active = self.rect.collidepoint(event.pos)
        elif event.type == pygame.KEYDOWN and self.active:
            if event.key == pygame.K_RETURN:
                self.active = False
                return True
            elif event.key == pygame.K_BACKSPACE:
                self.value = self.value[:-1]
            elif event.unicode.isprintable():
                self.value += event.unicode
        return False

class Button:
    def __init__(self, x, y, w, h, label, color, action):
        self.rect = pygame.Rect(x, y, w, h)
        self.label = label
        self.color = color
        self.action = action
        self.hover = False
        
    def draw(self, screen, font):
        color = tuple(min(c + 20, 255) for c in self.color) if self.hover else self.color
        pygame.draw.rect(screen, color, self.rect, border_radius=8)
        
        button_font = pygame.font.Font(None, 20)
        text_surf = button_font.render(self.label, True, COLOR_TEXT)
        text_rect = text_surf.get_rect(center=self.rect.center)
        screen.blit(text_surf, text_rect)
    
    def handle_event(self, event):
        if event.type == pygame.MOUSEMOTION:
            self.hover = self.rect.collidepoint(event.pos)
        elif event.type == pygame.MOUSEBUTTONDOWN:
            if self.rect.collidepoint(event.pos):
                self.action()
                return True
        return False

class Toggle:
    def __init__(self, x, y, label, key, default_value):
        self.rect = pygame.Rect(x, y, 20, 20)
        self.label = label
        self.key = key
        self.value = default_value
        
    def draw(self, screen, font):
        pygame.draw.rect(screen, (40, 40, 50), self.rect, border_radius=4)
        pygame.draw.rect(screen, (55, 65, 81), self.rect, 1, border_radius=4)
        
        if self.value:
            pygame.draw.rect(screen, COLOR_BLUE, self.rect.inflate(-8, -8), border_radius=2)
        
        toggle_font = pygame.font.Font(None, 19)
        label_surf = toggle_font.render(self.label, True, COLOR_TEXT)
        screen.blit(label_surf, (self.rect.x + 28, self.rect.y + 2))
    
    def handle_event(self, event):
        if event.type == pygame.MOUSEBUTTONDOWN:
            if self.rect.collidepoint(event.pos):
                self.value = not self.value
                return True
        return False

# Fonctions de conversion
def world_to_screen(x, y):
    sx = state['view_ox'] + x * state['view_scale']
    sy = WINDOW_HEIGHT - (state['view_oy'] + y * state['view_scale'])
    return (sx, sy)

def screen_to_world(sx, sy):
    x = (sx - state['view_ox']) / state['view_scale']
    y = (WINDOW_HEIGHT - sy - state['view_oy']) / state['view_scale']
    return (x, y)

def get_canvas_mouse_pos(mouse_pos):
    return (mouse_pos[0] - PANEL_WIDTH - 10, mouse_pos[1])

def auto_fit_view():
    canvas_w = max(400, WINDOW_WIDTH - PANEL_WIDTH - 20)
    canvas_h = max(300, WINDOW_HEIGHT - 40)
    margin = 40
    avail_w = canvas_w - 2 * margin
    avail_h = canvas_h - 2 * margin
    scale_w = avail_w / state['scene_w']
    scale_h = avail_h / state['scene_h']
    state['view_scale'] = min(scale_w, scale_h)
    grid_pix_w = state['scene_w'] * state['view_scale']
    grid_pix_h = state['scene_h'] * state['view_scale']
    state['view_ox'] = (canvas_w - grid_pix_w) / 2
    state['view_oy'] = (canvas_h - grid_pix_h) / 2

# Grille
def alloc_grid():
    state['grid_nx'] = max(1, math.ceil(state['scene_w'] / state['cell_size']))
    state['grid_ny'] = max(1, math.ceil(state['scene_h'] / state['cell_size']))
    state['grid_occ'] = [[0 for _ in range(state['grid_nx'])] for _ in range(state['grid_ny'])]

def clear_grid():
    for j in range(state['grid_ny']):
        for i in range(state['grid_nx']):
            state['grid_occ'][j][i] = 0

def mark_cell(i, j):
    if i == state['grid_nx']:
        i -= 1
    if j == state['grid_ny']:
        j -= 1
    if 0 <= i < state['grid_nx'] and 0 <= j < state['grid_ny']:
        state['grid_occ'][j][i] = 1

def rasterize_segment(x0, y0, x1, y1):
    x0 = max(0, min(state['scene_w'], x0))
    y0 = max(0, min(state['scene_h'], y0))
    x1 = max(0, min(state['scene_w'], x1))
    y1 = max(0, min(state['scene_h'], y1))
    
    cell = state['cell_size']
    epsilon = 1e-9
    
    i = int(x0 / cell)
    j = int(y0 / cell)
    i_end = int(x1 / cell)
    j_end = int(y1 / cell)
    
    mark_cell(i, j)
    
    dx = x1 - x0
    dy = y1 - y0
    step_i = 1 if dx > 0 else (-1 if dx < 0 else 0)
    step_j = 1 if dy > 0 else (-1 if dy < 0 else 0)
    inv_dx = 1 / dx if dx != 0 else 0
    inv_dy = 1 / dy if dy != 0 else 0
    
    if step_i != 0:
        xb = (i + 1) * cell if step_i > 0 else i * cell
        t_max_i = (xb - x0) * inv_dx
        t_delta_i = (cell * step_i) * inv_dx
    else:
        t_max_i = float('inf')
        t_delta_i = float('inf')
    
    if step_j != 0:
        yb = (j + 1) * cell if step_j > 0 else j * cell
        t_max_j = (yb - y0) * inv_dy
        t_delta_j = (cell * step_j) * inv_dy
    else:
        t_max_j = float('inf')
        t_delta_j = float('inf')
    
    while i != i_end or j != j_end:
        if t_max_i < t_max_j - epsilon:
            i += step_i
            mark_cell(i, j)
            t_max_i += t_delta_i
        elif t_max_j < t_max_i - epsilon:
            j += step_j
            mark_cell(i, j)
            t_max_j += t_delta_j
        else:
            i_prev, j_prev = i, j
            i += step_i
            j += step_j
            mark_cell(i, j)
            mark_cell(i_prev, j)
            mark_cell(i, j_prev)
            t_max_i += t_delta_i
            t_max_j += t_delta_j

def rebuild_grid_from_segments():
    clear_grid()
    for seg in state['segments']:
        rasterize_segment(seg.x1, seg.y1, seg.x2, seg.y2)

def add_segment(x1, y1, x2, y2):
    x1 = max(0, min(state['scene_w'], x1))
    y1 = max(0, min(state['scene_h'], y1))
    x2 = max(0, min(state['scene_w'], x2))
    y2 = max(0, min(state['scene_h'], y2))
    state['segments'].append(Segment(x1, y1, x2, y2))
    rasterize_segment(x1, y1, x2, y2)

def reset_segments():
    state['segments'].clear()
    clear_grid()
    if state['add_borders']:
        add_border_walls()

def add_border_walls():
    w, h = state['scene_w'], state['scene_h']
    add_segment(0, 0, w, 0)
    add_segment(w, 0, w, h)
    add_segment(w, h, 0, h)
    add_segment(0, h, 0, 0)

def find_segment_at_point(wx, wy, threshold=0.05):
    for idx, seg in enumerate(state['segments']):
        dist = distance_point_to_segment(wx, wy, seg.x1, seg.y1, seg.x2, seg.y2)
        if dist < threshold:
            return idx
    return -1

def distance_point_to_segment(px, py, x1, y1, x2, y2):
    dx = x2 - x1
    dy = y2 - y1
    len_sq = dx * dx + dy * dy
    if len_sq == 0:
        return math.sqrt((px - x1)**2 + (py - y1)**2)
    t = max(0, min(1, ((px - x1) * dx + (py - y1) * dy) / len_sq))
    proj_x = x1 + t * dx
    proj_y = y1 + t * dy
    return math.sqrt((px - proj_x)**2 + (py - proj_y)**2)

def delete_segment(index):
    if 0 <= index < len(state['segments']):
        state['segments'].pop(index)
        rebuild_grid_from_segments()

# Lidar
def ray_segment_intersection(px, py, rdx, rdy, x1, y1, x2, y2):
    sx = x2 - x1
    sy = y2 - y1
    denom = rdx * sy - rdy * sx
    if abs(denom) < 1e-10:
        return None
    
    dx = x1 - px
    dy = y1 - py
    t = (dx * sy - dy * sx) / denom
    u = (dx * rdy - dy * rdx) / denom
    
    if t > 1e-6 and -1e-6 <= u <= 1.0 + 1e-6:
        ix = px + t * rdx
        iy = py + t * rdy
        return {'t': t, 'ix': ix, 'iy': iy}
    return None

def random_noise(range_val):
    return (random.random() - 0.5) * 2 * range_val

def compute_scan():
    scan = []
    rx = state['robot']['x']
    ry = state['robot']['y']
    th0 = math.radians(state['robot']['th_deg'])
    
    for k in range(state['num_rays']):
        a_local = k * 2.0 * math.pi / state['num_rays']
        a_global = th0 + a_local
        rdx = math.cos(a_global)
        rdy = math.sin(a_global)
        
        best = None
        for seg in state['segments']:
            hit = ray_segment_intersection(rx, ry, rdx, rdy, seg.x1, seg.y1, seg.x2, seg.y2)
            if hit and (not best or hit['t'] < best['t']):
                best = hit
        
        if best:
            r = best['t']
            r_with_noise = max(0.001, r + random_noise(state['noise_dist']))
            a_local_with_noise = a_local + math.radians(random_noise(state['noise_angle']))
            
            scan.append({
                'angle_deg': math.degrees(a_local),
                'r_m': r_with_noise,
                'x_rel': r_with_noise * math.cos(a_local_with_noise),
                'y_rel': r_with_noise * math.sin(a_local_with_noise),
                'x_abs': best['ix'],
                'y_abs': best['iy'],
                'has_hit': True
            })
        else:
            scan.append({
                'angle_deg': math.degrees(a_local),
                'r_m': 0,
                'x_rel': 0,
                'y_rel': 0,
                'x_abs': rx,
                'y_abs': ry,
                'has_hit': False
            })
    
    return scan

# Export
def export_grid_csv():
    lines = [f"# Grid map {state['grid_nx']}x{state['grid_ny']}, cell={state['cell_size']} m ; 1=occupied,0=free"]
    for j in range(state['grid_ny'] - 1, -1, -1):
        lines.append(','.join(str(state['grid_occ'][j][i]) for i in range(state['grid_nx'])))
    
    path = Path('grid_map.csv')
    path.write_text('\n'.join(lines))
    print(f"✓ Grid map exporté : {path.absolute()}")

def export_vector_txt():
    lines = ["# Vector map segments: x1,y1,x2,y2 (meters)"]
    for seg in state['segments']:
        lines.append(f"{seg.x1:.4f},{seg.y1:.4f},{seg.x2:.4f},{seg.y2:.4f}")
    
    path = Path('vector_map.txt')
    path.write_text('\n'.join(lines))
    print(f"✓ Carte vectorielle exportée : {path.absolute()}")

def export_scan_csv():
    scan = compute_scan()
    lines = [
        f"# Robot position: x={state['robot']['x']:.4f}m, y={state['robot']['y']:.4f}m, theta={state['robot']['th_deg']:.2f}deg",
        "angle_deg,r_m,x_rel_m,y_rel_m"
    ]
    for pt in scan:
        lines.append(f"{pt['angle_deg']:.3f},{pt['r_m']:.4f},{pt['x_rel']:.4f},{pt['y_rel']:.4f}")
    
    path = Path('scan_lidar.csv')
    path.write_text('\n'.join(lines))
    print(f"✓ Scan Lidar exporté : {path.absolute()}")

def import_vector_map(filename):
    try:
        lines = Path(filename).read_text().split('\n')
        state['segments'].clear()
        for line in lines:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = [float(p.strip()) for p in line.split(',')]
            if len(parts) == 4:
                state['segments'].append(Segment(*parts))
        rebuild_grid_from_segments()
        print(f"✓ Carte importée : {len(state['segments'])} segments")
    except Exception as e:
        print(f"✗ Erreur import : {e}")

# Dessin
def draw_scene(screen, font):
    # Offset pour le canvas
    canvas_offset_x = PANEL_WIDTH + 10
    
    # Fond blanc
    top_left = world_to_screen(0, state['scene_h'])
    bottom_right = world_to_screen(state['scene_w'], 0)
    w = bottom_right[0] - top_left[0]
    h = bottom_right[1] - top_left[1]
    pygame.draw.rect(screen, COLOR_WHITE, (top_left[0] + canvas_offset_x, top_left[1], w, h))
    
    # Grille
    for i in range(state['grid_nx'] + 1):
        x = i * state['cell_size']
        p1 = world_to_screen(x, 0)
        p2 = world_to_screen(x, state['scene_h'])
        pygame.draw.line(screen, COLOR_GRID, (p1[0] + canvas_offset_x, p1[1]), (p2[0] + canvas_offset_x, p2[1]), 1)
    
    for j in range(state['grid_ny'] + 1):
        y = j * state['cell_size']
        p1 = world_to_screen(0, y)
        p2 = world_to_screen(state['scene_w'], y)
        pygame.draw.line(screen, COLOR_GRID, (p1[0] + canvas_offset_x, p1[1]), (p2[0] + canvas_offset_x, p2[1]), 1)
    
    # Cellules occupées
    for j in range(state['grid_ny']):
        for i in range(state['grid_nx']):
            if state['grid_occ'][j][i] == 1:
                x = i * state['cell_size']
                y = j * state['cell_size']
                p1 = world_to_screen(x, y)
                p2 = world_to_screen(x + state['cell_size'], y + state['cell_size'])
                pygame.draw.rect(screen, COLOR_BLACK, (p1[0] + canvas_offset_x, p1[1], p2[0] - p1[0], p2[1] - p1[1]))
    
    # Segments
    for seg in state['segments']:
        p1 = world_to_screen(seg.x1, seg.y1)
        p2 = world_to_screen(seg.x2, seg.y2)
        pygame.draw.line(screen, COLOR_RED, (p1[0] + canvas_offset_x, p1[1]), (p2[0] + canvas_offset_x, p2[1]), 3)
    
    # Scan Lidar
    if state['show_scan']:
        draw_lidar_scan(screen, canvas_offset_x)
    
    # Ligne en cours
    if state['dragging'] and state['drag_from']:
        p1 = world_to_screen(state['drag_from'][0], state['drag_from'][1])
        mouse_pos = pygame.mouse.get_pos()
        canvas_mouse = get_canvas_mouse_pos(mouse_pos)
        world_mouse = screen_to_world(canvas_mouse[0], canvas_mouse[1])
        wx = max(0, min(state['scene_w'], world_mouse[0]))
        wy = max(0, min(state['scene_h'], world_mouse[1]))
        p2 = world_to_screen(wx, wy)
        pygame.draw.line(screen, COLOR_ORANGE, (p1[0] + canvas_offset_x, p1[1]), (p2[0] + canvas_offset_x, p2[1]), 2)
    
    # Robot
    draw_robot(screen, canvas_offset_x)
    
    # Mode indicator
    if state['delete_mode']:
        text = font.render("MODE SUPPRESSION ACTIF", True, COLOR_RED)
        screen.blit(text, (WINDOW_WIDTH // 2 - 100, 20))

def draw_lidar_scan(screen, canvas_offset_x):
    scan = compute_scan()
    robot_screen = world_to_screen(state['robot']['x'], state['robot']['y'])
    robot_screen = (robot_screen[0] + canvas_offset_x, robot_screen[1])
    
    # Surface transparente pour les rayons
    surf = pygame.Surface((WINDOW_WIDTH, WINDOW_HEIGHT), pygame.SRCALPHA)
    
    for pt in scan:
        if pt['has_hit']:
            hit_screen = world_to_screen(pt['x_abs'], pt['y_abs'])
            hit_screen = (hit_screen[0] + canvas_offset_x, hit_screen[1])
            pygame.draw.line(surf, COLOR_CYAN_ALPHA, robot_screen, hit_screen, 1)
    
    screen.blit(surf, (0, 0))
    
    # Points
    for pt in scan:
        if pt['has_hit']:
            hit_screen = world_to_screen(pt['x_abs'], pt['y_abs'])
            hit_screen = (hit_screen[0] + canvas_offset_x, hit_screen[1])
            pygame.draw.circle(screen, COLOR_CYAN, hit_screen, 3)

def draw_robot(screen, canvas_offset_x):
    pos = world_to_screen(state['robot']['x'], state['robot']['y'])
    pos = (pos[0] + canvas_offset_x, pos[1])
    size = 0.12 * state['view_scale']
    th = -math.radians(state['robot']['th_deg'])
    
    points = [
        (size, 0),
        (-size * 0.6, size * 0.5),
        (-size * 0.6, -size * 0.5)
    ]
    
    rotated = []
    for px, py in points:
        rx = px * math.cos(th) - py * math.sin(th)
        ry = px * math.sin(th) + py * math.cos(th)
        rotated.append((pos[0] + rx, pos[1] + ry))
    
    pygame.draw.polygon(screen, COLOR_BLUE, rotated)
    pygame.draw.polygon(screen, (14, 165, 233), rotated, 2)

def create_ui_elements():
    elements = []
    y = 35
    x = 10
    w = 140
    
    font = pygame.font.Font(None, 20)
    
    # Champs texte - SCENE
    elements.append(UIField(x, y, w, 28, "Largeur (m)", 'scene_w', state['scene_w']))
    elements.append(UIField(x + w + 10, y, w, 28, "Hauteur (m)", 'scene_h', state['scene_h']))
    
    y += 50
    elements.append(UIField(x, y, w, 28, "Pas grille (m)", 'cell_size', state['cell_size']))
    elements.append(UIField(x + w + 10, y, w, 28, "Points Lidar", 'num_rays', state['num_rays']))
    
    y += 40
    elements.append(Toggle(x, y, "Murs bords", 'add_borders', state['add_borders']))
    elements.append(Toggle(x + 150, y, "Afficher scan", 'show_scan', state['show_scan']))
    
    y += 70
    # ROBOT
    elements.append(UIField(x, y, 90, 28, "X (m)", 'robot_x', state['robot']['x']))
    elements.append(UIField(x + 100, y, 90, 28, "Y (m)", 'robot_y', state['robot']['y']))
    elements.append(UIField(x + 200, y, 90, 28, "θ (°)", 'robot_th', state['robot']['th_deg']))
    
    y += 85
    # BRUIT
    elements.append(UIField(x, y, w, 28, "Angle (±°)", 'noise_angle', state['noise_angle']))
    elements.append(UIField(x + w + 10, y, w, 28, "Distance (±m)", 'noise_dist', state['noise_dist']))
    
    y += 100
    # ACTIONS
    elements.append(Button(x, y, 290, 28, "APPLIQUER PARAMETRES", COLOR_BLUE, apply_parameters))
    
    y += 40
    elements.append(Button(x, y, 140, 28, "EFFACER LIGNES", COLOR_RED, lambda: reset_segments()))
    elements.append(Button(x + 150, y, 140, 28, "MODE SUPPRESSION", COLOR_ORANGE, toggle_delete_mode))
    
    y += 40
    elements.append(Button(x, y, 140, 28, "EXPORT GRID CSV", COLOR_GREEN, export_grid_csv))
    elements.append(Button(x + 150, y, 140, 28, "EXPORT VECTOR TXT", COLOR_GREEN, export_vector_txt))
    
    y += 40
    elements.append(Button(x, y, 140, 28, "EXPORT SCAN CSV", COLOR_GREEN, export_scan_csv))
    
    return elements

def apply_parameters():
    try:
        for elem in ui_elements:
            if isinstance(elem, UIField):
                val = float(elem.value)
                if elem.key == 'scene_w':
                    state['scene_w'] = max(0.5, val)
                elif elem.key == 'scene_h':
                    state['scene_h'] = max(0.5, val)
                elif elem.key == 'cell_size':
                    state['cell_size'] = max(0.02, val)
                elif elem.key == 'num_rays':
                    state['num_rays'] = max(16, int(val))
                elif elem.key == 'robot_x':
                    state['robot']['x'] = max(0, min(state['scene_w'], val))
                elif elem.key == 'robot_y':
                    state['robot']['y'] = max(0, min(state['scene_h'], val))
                elif elem.key == 'robot_th':
                    state['robot']['th_deg'] = max(-180, min(180, val))
                elif elem.key == 'noise_angle':
                    state['noise_angle'] = max(0, val)
                elif elem.key == 'noise_dist':
                    state['noise_dist'] = max(0, val)
            elif isinstance(elem, Toggle):
                if elem.key == 'add_borders':
                    state['add_borders'] = elem.value
                elif elem.key == 'show_scan':
                    state['show_scan'] = elem.value
        
        alloc_grid()
        rebuild_grid_from_segments()
        auto_fit_view()
        print("✓ Paramètres appliqués")
    except Exception as e:
        print(f"✗ Erreur : {e}")

def toggle_delete_mode():
    state['delete_mode'] = not state['delete_mode']
    print(f"✓ Mode suppression {'activé' if state['delete_mode'] else 'désactivé'}")

# Main
def main():
    global ui_elements, WINDOW_WIDTH, WINDOW_HEIGHT
    
    screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT), pygame.RESIZABLE)
    pygame.display.set_caption("MapTool - Python")
    clock = pygame.time.Clock()
    font = pygame.font.Font(None, 22)
    
    alloc_grid()
    if state['add_borders']:
        add_border_walls()
    auto_fit_view()
    
    ui_elements = create_ui_elements()
    
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            
            # Gestion du redimensionnement
            elif event.type == pygame.VIDEORESIZE:
                WINDOW_WIDTH = event.w
                WINDOW_HEIGHT = event.h
                screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT), pygame.RESIZABLE)
                auto_fit_view()
            
            # UI events
            for elem in ui_elements:
                elem.handle_event(event)
            
            # Canvas events
            if event.type == pygame.MOUSEBUTTONDOWN and event.pos[0] > PANEL_WIDTH:
                canvas_mouse = get_canvas_mouse_pos(event.pos)
                world_pos = screen_to_world(canvas_mouse[0], canvas_mouse[1])
                wx, wy = world_pos
                
                if 0 <= wx <= state['scene_w'] and 0 <= wy <= state['scene_h']:
                    dx = wx - state['robot']['x']
                    dy = wy - state['robot']['y']
                    if math.sqrt(dx*dx + dy*dy) < 0.2:
                        state['dragging_robot'] = True
                    elif state['delete_mode']:
                        seg_idx = find_segment_at_point(wx, wy)
                        if seg_idx != -1:
                            delete_segment(seg_idx)
                    else:
                        state['dragging'] = True
                        state['drag_from'] = (wx, wy)
            
            elif event.type == pygame.MOUSEBUTTONUP:
                if state['dragging'] and state['drag_from']:
                    canvas_mouse = get_canvas_mouse_pos(event.pos)
                    world_pos = screen_to_world(canvas_mouse[0], canvas_mouse[1])
                    wx = max(0, min(state['scene_w'], world_pos[0]))
                    wy = max(0, min(state['scene_h'], world_pos[1]))
                    add_segment(state['drag_from'][0], state['drag_from'][1], wx, wy)
                    state['dragging'] = False
                    state['drag_from'] = None
                state['dragging_robot'] = False
            
            elif event.type == pygame.MOUSEMOTION:
                if state['dragging_robot']:
                    canvas_mouse = get_canvas_mouse_pos(event.pos)
                    world_pos = screen_to_world(canvas_mouse[0], canvas_mouse[1])
                    state['robot']['x'] = max(0, min(state['scene_w'], world_pos[0]))
                    state['robot']['y'] = max(0, min(state['scene_h'], world_pos[1]))
                    # Mettre à jour les champs UI
                    for elem in ui_elements:
                        if isinstance(elem, UIField):
                            if elem.key == 'robot_x' and not elem.active:
                                elem.value = f"{state['robot']['x']:.2f}"
                            elif elem.key == 'robot_y' and not elem.active:
                                elem.value = f"{state['robot']['y']:.2f}"
            
            elif event.type == pygame.MOUSEWHEEL:
                mouse_pos = pygame.mouse.get_pos()
                if event.y != 0 and mouse_pos[0] > PANEL_WIDTH:
                    canvas_mouse = get_canvas_mouse_pos(mouse_pos)
                    world_pos = screen_to_world(canvas_mouse[0], canvas_mouse[1])
                    wx, wy = world_pos
                    dx = wx - state['robot']['x']
                    dy = wy - state['robot']['y']
                    if math.sqrt(dx*dx + dy*dy) < 0.2:
                        state['robot']['th_deg'] = max(-180, min(180, state['robot']['th_deg'] + event.y * 5))
                        # Mettre à jour le champ UI
                        for elem in ui_elements:
                            if isinstance(elem, UIField) and elem.key == 'robot_th' and not elem.active:
                                elem.value = str(int(state['robot']['th_deg']))
            
            elif event.type == pygame.KEYDOWN:
                step = 0.05
                rot = 5
                moved = False
                
                if event.key == pygame.K_RIGHT:
                    state['robot']['x'] += step
                    moved = True
                elif event.key == pygame.K_LEFT:
                    state['robot']['x'] -= step
                    moved = True
                elif event.key == pygame.K_UP:
                    state['robot']['y'] += step
                    moved = True
                elif event.key == pygame.K_DOWN:
                    state['robot']['y'] -= step
                    moved = True
                elif event.key == pygame.K_PAGEUP:
                    state['robot']['th_deg'] += rot
                    moved = True
                elif event.key == pygame.K_PAGEDOWN:
                    state['robot']['th_deg'] -= rot
                    moved = True
                
                if moved:
                    state['robot']['x'] = max(0, min(state['scene_w'], state['robot']['x']))
                    state['robot']['y'] = max(0, min(state['scene_h'], state['robot']['y']))
                    state['robot']['th_deg'] = max(-180, min(180, state['robot']['th_deg']))
                    # Mettre à jour les champs UI
                    for elem in ui_elements:
                        if isinstance(elem, UIField) and not elem.active:
                            if elem.key == 'robot_x':
                                elem.value = f"{state['robot']['x']:.2f}"
                            elif elem.key == 'robot_y':
                                elem.value = f"{state['robot']['y']:.2f}"
                            elif elem.key == 'robot_th':
                                elem.value = str(int(state['robot']['th_deg']))
        
        # Dessin
        screen.fill(COLOR_BG)
        
        # Panel
        pygame.draw.rect(screen, COLOR_PANEL, (0, 0, PANEL_WIDTH, WINDOW_HEIGHT))
        
        # Titres
        title_font = pygame.font.Font(None, 22)
        
        y = 5
        title = title_font.render("PARAMETRES SCENE", True, COLOR_TEXT)
        screen.blit(title, (10, y))
        
        y = 160
        title = title_font.render("ROBOT", True, COLOR_TEXT)
        screen.blit(title, (10, y))
        
        y = 245
        title = title_font.render("BRUIT LIDAR", True, COLOR_TEXT)
        screen.blit(title, (10, y))
        
        y = 350
        title = title_font.render("ACTIONS", True, COLOR_TEXT)
        screen.blit(title, (10, y))
        
        y = 560
        title = title_font.render("AIDE", True, COLOR_TEXT)
        screen.blit(title, (10, y))
        
        help_font = pygame.font.Font(None, 17)
        y = 582
        helps = [
            "• Tracer: clic-glisser sur zone vide",
            "• Supprimer: clic près d'une ligne en mode suppression",
            "• Robot: clic-glisser / molette ou",
            "• Flèches du clavier + PageUp/PageDown",
            "• Cliquez sur un champs pour le modifier",
            "• Appuyez sur Entrer pour valider un champ"
        ]
        for help_text in helps:
            text = help_font.render(help_text, True, COLOR_MUTED)
            screen.blit(text, (10, y))
            y += 17
        
        # UI Elements
        for elem in ui_elements:
            elem.draw(screen, font)
        
        # Scene
        pygame.draw.rect(screen, (11, 18, 32), (PANEL_WIDTH + 10, 0, WINDOW_WIDTH - PANEL_WIDTH - 10, WINDOW_HEIGHT))
        draw_scene(screen, font)
        
        # Copyright
        copy_font = pygame.font.Font(None, 18)
        copy_text = copy_font.render("© QUILLES Jonathan (2026)", True, (150, 150, 150))
        screen.blit(copy_text, (WINDOW_WIDTH - 180, WINDOW_HEIGHT - 20))
        
        pygame.display.flip()
        clock.tick(FPS)
    
    pygame.quit()
    sys.exit()

if __name__ == '__main__':
    main()