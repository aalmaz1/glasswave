import { useState, useRef, useEffect } from "react";
import { flushSync } from "react-dom";
import {
  Plus, Archive, Trash2, FileText, Link2,
  X, Hash, Clock, Check, User, LogOut,
  Settings, ChevronLeft, Type, Palette, Eye, EyeOff,
  Pin, PinOff, Shield, Bell, BellRing, CalendarClock,
  SlidersHorizontal, CalendarDays, RefreshCw, Shuffle,
} from "lucide-react";

/* ════════════════════════════════════════════════════════════════════
   DESIGN TOKENS
   ════════════════════════════════════════════════════════════════════ */
const G = {
  bg:            "rgba(255,255,255,0.06)",
  bgHov:         "rgba(255,255,255,0.10)",
  border:        "rgba(255,255,255,0.20)",
  borderHov:     "rgba(255,255,255,0.40)",
  shadow:        "0 10px 40px rgba(0,0,0,0.50), inset 0 1px 0 rgba(255,255,255,0.15), inset 0 -1px 0 rgba(0,0,0,0.20)",
  shadowHov:     "0 20px 60px rgba(0,0,0,0.60), inset 0 1px 0 rgba(255,255,255,0.25), inset 0 -1px 0 rgba(0,0,0,0.20)",
  radius:        20,
  textPrimary:   "rgba(255,255,255,0.92)",
  textSecondary: "rgba(255,255,255,0.60)",
  textMuted:     "rgba(255,255,255,0.30)",
  overlay:       "rgba(0,0,0,0.50)",
};

function glassBase(blur = 24): React.CSSProperties {
  return {
    background:           G.bg,
    backdropFilter:       `blur(${blur}px)`,
    WebkitBackdropFilter: `blur(${blur}px)`,
    border:               `1px solid ${G.border}`,
    boxShadow:            G.shadow,
    borderRadius:         G.radius,
  };
}

/* ════════════════════════════════════════════════════════════════════
   THEMES  (8 total)
   ════════════════════════════════════════════════════════════════════ */
type ThemeId = "sunset" | "ice" | "mono" | "cyber" | "aurora" | "rose" | "cosmos" | "forest"
             | "obsidian" | "graphite" | "midnight" | "espresso";
type Theme = {
  id: ThemeId; name: string; emoji: string; bg: string;
  orbs: { color: string; size: number; top: string; left: string }[];
  accents: string[];
};

const THEMES: Theme[] = [
  {
    id:"sunset", name:"Тёплый закат", emoji:"🌅",
    bg:"linear-gradient(145deg,#130500 0%,#2E0C00 28%,#4A1400 52%,#6B1E00 75%,#8A2800 100%)",
    orbs:[
      {color:"rgba(255,110,20,0.22)", size:680,top:"-18%",left:"-10%"},
      {color:"rgba(200,50,0,0.16)",   size:520,top:"38%",  left:"58%"},
      {color:"rgba(255,160,30,0.10)", size:400,top:"72%",  left:"5%" },
      {color:"rgba(180,40,0,0.09)",   size:280,top:"12%",  left:"72%"},
    ],
    accents:["rgba(255,150,50,0.09)","rgba(255,90,30,0.08)","rgba(240,190,60,0.07)","rgba(210,70,10,0.08)"],
  },
  {
    id:"ice", name:"Ледяная свежесть", emoji:"🧊",
    bg:"linear-gradient(145deg,#00080F 0%,#001525 30%,#002440 58%,#003658 80%,#004870 100%)",
    orbs:[
      {color:"rgba(0,180,230,0.18)",  size:620,top:"-12%",left:"-8%"},
      {color:"rgba(0,120,190,0.14)",  size:500,top:"40%",  left:"62%"},
      {color:"rgba(60,210,220,0.09)", size:380,top:"68%",  left:"4%" },
      {color:"rgba(100,180,255,0.08)",size:260,top:"15%",  left:"70%"},
    ],
    accents:["rgba(40,200,255,0.08)","rgba(0,180,200,0.08)","rgba(80,170,255,0.07)","rgba(0,150,210,0.08)"],
  },
  {
    id:"mono", name:"Монохром", emoji:"🪨",
    bg:"linear-gradient(150deg,#0E0E10 0%,#141416 35%,#1A1A1C 65%,#111113 100%)",
    orbs:[
      {color:"rgba(200,200,220,0.07)", size:700,top:"-15%",left:"-8%"},
      {color:"rgba(160,160,190,0.05)", size:520,top:"42%",  left:"60%"},
      {color:"rgba(100,110,180,0.04)", size:360,top:"70%",  left:"5%" },
    ],
    accents:["rgba(220,220,240,0.07)","rgba(150,160,255,0.06)","rgba(255,150,200,0.05)","rgba(190,190,210,0.06)"],
  },
  {
    id:"cyber", name:"Кибер-закат", emoji:"🌺",
    bg:"linear-gradient(140deg,#001212 0%,#002828 30%,#004040 55%,#003535 70%,#380A20 100%)",
    orbs:[
      {color:"rgba(0,220,200,0.20)",  size:600,top:"-12%",left:"-7%"},
      {color:"rgba(200,30,90,0.18)",  size:540,top:"38%",  left:"58%"},
      {color:"rgba(0,180,170,0.10)",  size:380,top:"72%",  left:"5%" },
      {color:"rgba(160,20,80,0.09)",  size:280,top:"10%",  left:"70%"},
    ],
    accents:["rgba(0,230,210,0.08)","rgba(210,40,110,0.08)","rgba(0,200,190,0.07)","rgba(180,30,100,0.07)"],
  },
  {
    id:"aurora", name:"Северное сияние", emoji:"🌌",
    bg:"linear-gradient(155deg,#010806 0%,#031A0E 28%,#051828 55%,#090B22 80%,#06041A 100%)",
    orbs:[
      {color:"rgba(0,240,120,0.18)",  size:660,top:"-16%",left:"-9%"},
      {color:"rgba(60,30,230,0.20)",  size:560,top:"36%",  left:"56%"},
      {color:"rgba(0,190,170,0.11)",  size:400,top:"70%",  left:"3%" },
      {color:"rgba(120,0,255,0.09)",  size:320,top:"8%",   left:"68%"},
      {color:"rgba(0,255,160,0.07)",  size:240,top:"55%",  left:"20%"},
    ],
    accents:["rgba(0,255,130,0.07)","rgba(80,50,255,0.07)","rgba(0,210,180,0.07)","rgba(100,255,190,0.06)"],
  },
  {
    id:"rose", name:"Полночная роза", emoji:"🥀",
    bg:"linear-gradient(145deg,#0A0005 0%,#180008 32%,#260010 60%,#180018 82%,#0E000C 100%)",
    orbs:[
      {color:"rgba(230,0,80,0.22)",   size:620,top:"-14%",left:"-8%"},
      {color:"rgba(150,0,200,0.17)",  size:520,top:"38%",  left:"60%"},
      {color:"rgba(255,60,120,0.10)", size:380,top:"68%",  left:"4%" },
      {color:"rgba(120,0,180,0.08)",  size:300,top:"15%",  left:"70%"},
    ],
    accents:["rgba(255,50,110,0.08)","rgba(210,0,150,0.08)","rgba(190,0,255,0.07)","rgba(255,100,170,0.07)"],
  },
  {
    id:"cosmos", name:"Глубокий космос", emoji:"🔭",
    bg:"linear-gradient(148deg,#020008 0%,#08001E 32%,#110030 60%,#08001A 82%,#030010 100%)",
    orbs:[
      {color:"rgba(110,0,255,0.20)",  size:640,top:"-15%",left:"-8%"},
      {color:"rgba(60,0,210,0.16)",   size:520,top:"40%",  left:"58%"},
      {color:"rgba(180,60,255,0.09)", size:380,top:"72%",  left:"6%" },
      {color:"rgba(255,120,255,0.06)",size:280,top:"18%",  left:"72%"},
      {color:"rgba(80,0,200,0.06)",   size:220,top:"50%",  left:"28%"},
    ],
    accents:["rgba(130,50,255,0.08)","rgba(190,70,255,0.07)","rgba(255,130,255,0.06)","rgba(90,0,210,0.08)"],
  },
  {
    id:"forest", name:"Тёмный лес", emoji:"🌲",
    bg:"linear-gradient(145deg,#010602 0%,#030E05 30%,#061808 58%,#081E0A 80%,#040C06 100%)",
    orbs:[
      {color:"rgba(0,190,55,0.17)",   size:620,top:"-13%",left:"-7%"},
      {color:"rgba(0,130,35,0.13)",   size:500,top:"40%",  left:"62%"},
      {color:"rgba(40,210,70,0.08)",  size:380,top:"70%",  left:"5%" },
      {color:"rgba(160,255,80,0.06)", size:260,top:"14%",  left:"68%"},
    ],
    accents:["rgba(0,210,75,0.07)","rgba(50,190,60,0.07)","rgba(130,255,70,0.06)","rgba(0,150,55,0.07)"],
  },
  /* ── DARK SOLID / TONAL THEMES ───────────────────────────────────── */
  {
    id:"obsidian", name:"Обсидиан", emoji:"🪬",
    /* Real obsidian: volcanic glass, deep black with a blue-green subsurface sheen */
    bg:"linear-gradient(158deg,#08080C 0%,#0C0C12 35%,#090B10 65%,#07070A 100%)",
    orbs:[
      {color:"rgba(40,60,140,0.22)",  size:800,top:"-25%",left:"-15%"},
      {color:"rgba(20,40,100,0.16)",  size:620,top:"45%",  left:"50%"},
      {color:"rgba(60,80,160,0.10)",  size:420,top:"75%",  left:"-5%"},
      {color:"rgba(0,30,80,0.12)",    size:300,top:"5%",   left:"65%"},
    ],
    accents:["rgba(60,80,200,0.06)","rgba(40,60,180,0.06)","rgba(80,100,220,0.05)","rgba(30,50,160,0.06)"],
  },
  {
    id:"graphite", name:"Графит", emoji:"🩶",
    /* Premium carbon: cool dark with subtle warm-neutral variation */
    bg:"linear-gradient(152deg,#111113 0%,#161618 38%,#191919 62%,#111112 100%)",
    orbs:[
      {color:"rgba(180,185,210,0.10)", size:750,top:"-20%",left:"-12%"},
      {color:"rgba(140,145,175,0.07)", size:560,top:"42%",  left:"52%"},
      {color:"rgba(100,105,150,0.05)", size:380,top:"70%",  left:"-4%"},
      {color:"rgba(200,195,220,0.04)", size:280,top:"10%",  left:"68%"},
    ],
    accents:["rgba(210,215,235,0.06)","rgba(160,165,200,0.06)","rgba(130,135,185,0.05)","rgba(185,190,215,0.05)"],
  },
  {
    id:"midnight", name:"Полночь", emoji:"🌑",
    /* Deep night sky: rich dark navy, no moon */
    bg:"linear-gradient(148deg,#040610 0%,#080C1C 32%,#0C1028 60%,#070A1A 82%,#040610 100%)",
    orbs:[
      {color:"rgba(30,50,160,0.25)",  size:720,top:"-20%",left:"-12%"},
      {color:"rgba(20,35,120,0.18)",  size:560,top:"42%",  left:"54%"},
      {color:"rgba(50,70,190,0.10)",  size:400,top:"72%",  left:"4%" },
      {color:"rgba(15,25,100,0.12)",  size:300,top:"8%",   left:"66%"},
    ],
    accents:["rgba(80,110,255,0.07)","rgba(60,90,230,0.07)","rgba(50,80,210,0.06)","rgba(100,130,255,0.06)"],
  },
  {
    id:"espresso", name:"Эспрессо", emoji:"☕",
    /* Freshly brewed: deep warm brown with golden crema undertones */
    bg:"linear-gradient(150deg,#0E0804 0%,#160C05 32%,#1C1008 60%,#140B06 82%,#0D0703 100%)",
    orbs:[
      {color:"rgba(160,80,10,0.22)",  size:700,top:"-18%",left:"-10%"},
      {color:"rgba(120,55,5,0.16)",   size:540,top:"42%",  left:"54%"},
      {color:"rgba(200,120,20,0.08)", size:380,top:"70%",  left:"4%" },
      {color:"rgba(100,45,0,0.10)",   size:280,top:"10%",  left:"68%"},
    ],
    accents:["rgba(210,150,60,0.07)","rgba(190,115,35,0.07)","rgba(230,170,80,0.06)","rgba(170,95,25,0.06)"],
  },
];

/* ════════════════════════════════════════════════════════════════════
   GLOBAL CSS
   ════════════════════════════════════════════════════════════════════ */
const CSS = `
  *,*::before,*::after{box-sizing:border-box;}

  .card{
    border-radius:${G.radius}px;
    transform-origin:center center;
    backface-visibility:hidden;-webkit-backface-visibility:hidden;
    will-change:transform;cursor:pointer;
    transition:transform 0.32s cubic-bezier(0.34,1.56,0.64,1),box-shadow 0.28s ease;
  }
  .card:hover{transform:translateY(-6px) scale(1.02);}

  .card-glass{
    border-radius:${G.radius}px;overflow:hidden;position:relative;
    background:${G.bg};backdrop-filter:blur(24px);-webkit-backdrop-filter:blur(24px);
    border:1px solid ${G.border};box-shadow:${G.shadow};
    transition:box-shadow 0.28s ease,border-color 0.28s ease,background 0.28s ease;
  }
  .card:hover .card-glass{background:${G.bgHov};border-color:${G.borderHov};box-shadow:${G.shadowHov};}

  .glass-ring{
    position:absolute;inset:0;border-radius:inherit;pointer-events:none;z-index:10;padding:1px;
    background:linear-gradient(160deg,rgba(255,255,255,0.35) 0%,rgba(255,255,255,0.08) 40%,rgba(255,255,255,0.02) 100%);
    -webkit-mask:linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0);
    -webkit-mask-composite:xor;mask-composite:exclude;transition:background 0.28s;
  }
  .card:hover .glass-ring{
    background:linear-gradient(160deg,rgba(255,255,255,0.60) 0%,rgba(255,255,255,0.14) 45%,rgba(255,255,255,0.02) 100%);
  }

  .glass-sheen{
    position:absolute;inset:0;border-radius:inherit;pointer-events:none;z-index:9;
    background:linear-gradient(45deg,rgba(255,255,255,0.06) 0%,transparent 50%,rgba(255,255,255,0.03) 100%);
    opacity:0.6;transition:opacity 0.28s;
  }
  .card:hover .glass-sheen{opacity:1;}

  .card-accent{
    position:absolute;inset:0;border-radius:inherit;pointer-events:none;z-index:8;transition:filter 0.28s;
  }
  .card:hover .card-accent{filter:brightness(1.6);}

  .card-actions{opacity:0;transition:opacity 0.20s;}
  .card:hover .card-actions{opacity:1;}
  .actions-always{opacity:1!important;}

  .card-pin{opacity:0;transform:scale(0.75);transition:opacity 0.20s,transform 0.20s;}
  .card:hover .card-pin,.card-pin.pinned{opacity:1;transform:scale(1);}

  input[type="datetime-local"]{color-scheme:dark;}
  input[type="datetime-local"]:focus{border-color:rgba(255,200,60,0.55)!important;outline:none;}

  @keyframes slideUp{
    from{transform:translateY(100%);}
    to{transform:translateY(0);}
  }
  .sheet-in{animation:slideUp 0.28s cubic-bezier(0.32,0.72,0,1) both;}

  @keyframes bellRing{
    0%,100%{transform:rotate(0);}
    15%{transform:rotate(14deg);}
    30%{transform:rotate(-10deg);}
    45%{transform:rotate(8deg);}
    60%{transform:rotate(-5deg);}
    75%{transform:rotate(3deg);}
  }
  .bell-active{animation:bellRing 0.7s ease both;}

  .masonry{columns:var(--cols,3);column-gap:16px;}
  .masonry .card{break-inside:avoid;margin-bottom:16px;display:block;}
  .masonry .card:hover{transform:translateY(-4px) scale(1.01);}

  .scroll-host{scrollbar-width:thin;scrollbar-color:rgba(255,255,255,0.10) transparent;}
  .scroll-host::-webkit-scrollbar{width:4px;}
  .scroll-host::-webkit-scrollbar-thumb{background:rgba(255,255,255,0.10);border-radius:4px;}

  .search-bar:focus-within{
    border-color:rgba(255,255,255,0.40)!important;
    box-shadow:0 12px 40px rgba(0,0,0,0.55),inset 0 1px 0 rgba(255,255,255,0.22)!important;
  }

  @keyframes modalIn{
    from{opacity:0;transform:translateY(22px) scale(0.97);}
    to{opacity:1;transform:none;}
  }
  .modal-in{animation:modalIn 0.30s cubic-bezier(0.34,1.46,0.64,1) both;}

  .section-label{
    font-size:0.68rem;font-weight:600;letter-spacing:0.09em;text-transform:uppercase;
    color:rgba(255,255,255,0.30);margin:0 0 12px 4px;
  }

  .fmt-btn{
    width:34px;height:30px;border-radius:8px;border:none;cursor:pointer;
    font-family:'Inter',monospace;font-size:0.76rem;font-weight:700;
    background:transparent;color:rgba(255,255,255,0.30);
    transition:background 0.15s,color 0.15s;
    display:flex;align-items:center;justify-content:center;
    user-select:none;-webkit-user-select:none;
  }
  .fmt-btn:hover{background:rgba(255,255,255,0.09);color:rgba(255,255,255,0.90);}
  .fmt-btn:active{background:rgba(255,255,255,0.14);}

  .icon-btn{
    width:36px;height:36px;border-radius:50%;border:none;cursor:pointer;
    background:transparent;display:flex;align-items:center;justify-content:center;
    transition:background 0.18s;flex-shrink:0;
  }
  .icon-btn:hover{background:rgba(255,255,255,0.08);}
`;

/* ════════════════════════════════════════════════════════════════════
   TYPES
   ════════════════════════════════════════════════════════════════════ */
type Note = {
  id:number; title:string; body:string; updatedAt:Date;
  accentIdx:number; pinned:boolean; archived:boolean; trashed:boolean;
  reminder:Date|null;
};
type Screen    = "dashboard" | "settings";
type Tab       = "all" | "archive" | "trash";
type SortOrder = "default" | "created" | "updated";

/* ════════════════════════════════════════════════════════════════════
   AUTH  (localStorage-backed, no server required)
   ════════════════════════════════════════════════════════════════════ */
type AuthUser = { email: string; name: string };
type StoredUser = { email: string; name: string; pw: string }; // pw = btoa(password)

const LS_USERS  = "noova_users";
const LS_NOTES  = (email: string) => `noova_notes_${email}`;
const LS_PREFS  = (email: string) => `noova_prefs_${email}`;
const LS_ME     = "noova_me";

function lsGetUsers(): StoredUser[] {
  try { return JSON.parse(localStorage.getItem(LS_USERS) || "[]"); } catch { return []; }
}
function lsSaveUsers(u: StoredUser[]) { localStorage.setItem(LS_USERS, JSON.stringify(u)); }

function lsGetNotes(email: string): Note[] | null {
  try {
    const raw = localStorage.getItem(LS_NOTES(email));
    if (!raw) return null;
    const arr = JSON.parse(raw);
    return arr.map((n: Note) => ({
      ...n,
      updatedAt: new Date(n.updatedAt),
      reminder: n.reminder ? new Date(n.reminder) : null,
    }));
  } catch { return null; }
}
function lsSaveNotes(email: string, notes: Note[]) {
  localStorage.setItem(LS_NOTES(email), JSON.stringify(notes));
}

function lsGetPrefs(email: string): { themeId?: ThemeId } {
  try { return JSON.parse(localStorage.getItem(LS_PREFS(email)) || "{}"); } catch { return {}; }
}
function lsSavePrefs(email: string, p: { themeId: ThemeId }) {
  localStorage.setItem(LS_PREFS(email), JSON.stringify(p));
}

function authRegister(email: string, name: string, pw: string): string | null {
  email = email.trim().toLowerCase();
  if (!email.includes("@")) return "Введите корректный email";
  if (name.trim().length < 2)  return "Имя должно быть не короче 2 символов";
  if (pw.length < 6)           return "Пароль должен быть не менее 6 символов";
  const users = lsGetUsers();
  if (users.find(u => u.email === email)) return "Аккаунт с таким email уже существует";
  users.push({ email, name: name.trim(), pw: btoa(pw) });
  lsSaveUsers(users);
  localStorage.setItem(LS_ME, JSON.stringify({ email, name: name.trim() }));
  return null;
}

function authLogin(email: string, pw: string): string | null {
  email = email.trim().toLowerCase();
  const users = lsGetUsers();
  const u = users.find(u => u.email === email);
  if (!u) return "Аккаунт не найден";
  if (u.pw !== btoa(pw)) return "Неверный пароль";
  localStorage.setItem(LS_ME, JSON.stringify({ email: u.email, name: u.name }));
  return null;
}

function authGetMe(): AuthUser | null {
  try { return JSON.parse(localStorage.getItem(LS_ME) || "null"); } catch { return null; }
}

function authLogout() { localStorage.removeItem(LS_ME); }

/* ════════════════════════════════════════════════════════════════════
   SEED DATA
   ════════════════════════════════════════════════════════════════════ */
const SEED: Note[] = [
  {id:1,title:"Product Roadmap Q3",  body:"Launch mobile redesign by August 15. Milestones: design handoff Jul 20, beta Aug 1, soft launch Aug 10. Coordinate with Elena on onboarding flow.",updatedAt:new Date("2026-07-11T14:30:00"),accentIdx:0,pinned:true, archived:false,trashed:false,reminder:null},
  {id:2,title:"Design Sprint Notes", body:"Decided on glassmorphism for v2. Action items: component library, Figma tokens, user testing schedule.",                                               updatedAt:new Date("2026-07-10T09:15:00"),accentIdx:1,pinned:false,archived:false,trashed:false,reminder:null},
  {id:3,title:"Reading List",        body:"Thinking in Systems — Meadows.\nA Pattern Language — Alexander.\nWorking in Public — Nadia Eghbal.\nFinite and Infinite Games — Carse.",            updatedAt:new Date("2026-07-09T18:00:00"),accentIdx:2,pinned:true, archived:false,trashed:false,reminder:null},
  {id:4,title:"API Integration",     body:"Auth: /v2/auth/token. Rate limit 1000 req/min. Headers: X-API-Key, Content-Type. Exponential backoff from 500ms.",                                   updatedAt:new Date("2026-07-08T11:45:00"),accentIdx:3,pinned:false,archived:false,trashed:false,reminder:null},
  {id:5,title:"Weekly Reflection",   body:"Good progress on dashboard. Animation timing sluggish on low-end — profile render pipeline. Fix modal state bug.",                                    updatedAt:new Date("2026-07-07T20:00:00"),accentIdx:0,pinned:false,archived:false,trashed:false,reminder:null},
  {id:6,title:"Miso Ramen Recipe",   body:"Base: white miso 3 tbsp, dashi 4 cups, soy 2 tbsp.\nToppings: soft-boiled egg (6h), chashu pork, menma, nori.",                                     updatedAt:new Date("2026-07-06T13:20:00"),accentIdx:1,pinned:false,archived:false,trashed:false,reminder:null},
  {id:7,title:"CSS Deep Dive",       body:"backdrop-filter needs -webkit- in Safari. Container queries: broad support now. @layer controls specificity cleanly.",                                updatedAt:new Date("2026-07-05T16:50:00"),accentIdx:2,pinned:false,archived:false,trashed:false,reminder:null},
  {id:8,title:"Kyoto Itinerary",     body:"Day 1: Fushimi Inari at dawn, Nishiki Market. Day 2: Arashiyama, Tenryu-ji. Day 3: Philosopher's Path, Nanzen-ji.",                                 updatedAt:new Date("2026-07-04T10:10:00"),accentIdx:3,pinned:false,archived:true, trashed:false,reminder:null},
];

function fmtDate(d:Date){
  const h=(Date.now()-d.getTime())/3600000;
  if(h<1)  return "Только что";
  if(h<24) return `${Math.floor(h)}ч назад`;
  const day=Math.floor(h/24);
  if(day<7)return `${day}д назад`;
  return d.toLocaleDateString("ru-RU",{month:"short",day:"numeric"});
}

function useWidth(){
  const [w,setW]=useState(typeof window!=="undefined"?window.innerWidth:1280);
  useEffect(()=>{const h=()=>setW(window.innerWidth);window.addEventListener("resize",h);return()=>window.removeEventListener("resize",h);},[]);
  return w;
}

/* ════════════════════════════════════════════════════════════════════
   ROOT
   ════════════════════════════════════════════════════════════════════ */
export default function App(){
  const initUser = authGetMe();
  const initPrefs = initUser ? lsGetPrefs(initUser.email) : {};
  const initNotes = initUser ? (lsGetNotes(initUser.email) ?? SEED) : SEED;

  const [currentUser, setCurrentUser] = useState<AuthUser|null>(initUser);
  const [themeId, setThemeIdRaw]  = useState<ThemeId>(initPrefs.themeId ?? "sunset");
  const [screen,  setScreen]   = useState<Screen>("dashboard");
  const [tab,     setTab]      = useState<Tab>("all");
  const [notes,   setNotesRaw]    = useState<Note[]>(initNotes);
  const [editing, setEditing]  = useState<Note|null>(null);
  const [creating,setCreating] = useState(false);
  const [draftT,  setDraftT]   = useState("");
  const [draftB,  setDraftB]   = useState("");
  const [search,  setSearch]       = useState("");
  const [scrollY, setScrollY]      = useState(0);
  const [reminderNoteId, setReminderNoteId] = useState<number|null>(null);
  const [sort,    setSort]     = useState<SortOrder>("default");
  const [showSort,setShowSort] = useState(false);

  const bodyRef  = useRef<HTMLTextAreaElement>(null);
  const selRef   = useRef<{start:number;end:number}>({start:0,end:0});
  const width    = useWidth();
  const isMobile = width < 768;
  const isTablet = width >= 768 && width < 1280;
  const theme    = THEMES.find(t=>t.id===themeId)!;

  /* Persist notes whenever they change */
  const setNotes = (fn: Note[] | ((p:Note[])=>Note[])) => {
    setNotesRaw(prev => {
      const next = typeof fn === "function" ? fn(prev) : fn;
      if (currentUser) lsSaveNotes(currentUser.email, next);
      return next;
    });
  };

  const setThemeId = (id: ThemeId) => {
    setThemeIdRaw(id);
    if (currentUser) lsSavePrefs(currentUser.email, { themeId: id });
  };

  const handleLogin = (user: AuthUser) => {
    setCurrentUser(user);
    const prefs = lsGetPrefs(user.email);
    if (prefs.themeId) setThemeIdRaw(prefs.themeId);
    const saved = lsGetNotes(user.email);
    setNotesRaw(saved ?? SEED);
  };

  const handleLogout = () => {
    authLogout();
    setCurrentUser(null);
    setThemeIdRaw("sunset");
    setNotesRaw(SEED);
  };

  const openEdit  = (n:Note)=>{ setEditing(n); setCreating(false); setDraftT(n.title); setDraftB(n.body); };
  const openNew   = ()=>{ setEditing(null); setCreating(true); setDraftT(""); setDraftB(""); };
  const closeEd   = ()=>{ setEditing(null); setCreating(false); };

  const save=()=>{
    if(!draftT.trim()&&!draftB.trim()){closeEd();return;}
    if(creating){
      setNotes(p=>[{id:Date.now(),title:draftT||"Без названия",body:draftB,updatedAt:new Date(),
        accentIdx:Math.floor(Math.random()*theme.accents.length),pinned:false,archived:false,trashed:false},...p]);
    } else if(editing){
      setNotes(p=>p.map(n=>n.id===editing.id?{...n,title:draftT||"Без названия",body:draftB,updatedAt:new Date()}:n));
    }
    closeEd();
  };

  /* ── Format insertion ──
     flushSync forces React to commit the new textarea value to the DOM
     synchronously before we call setSelectionRange — otherwise React 18's
     async scheduler may not have updated textarea.value yet.              */
  const insertFmt=(pre:string,post="",linePrefix=false)=>{
    const ta=bodyRef.current; if(!ta)return;
    const s=selRef.current.start;
    const e=selRef.current.end;
    const val=draftB;

    if(linePrefix){
      const lineStart=val.lastIndexOf("\n",s-1)+1;
      const alreadyHas=val.slice(lineStart).startsWith(pre);
      let newVal:string; let newCursor:number;
      if(alreadyHas){
        newVal=val.slice(0,lineStart)+val.slice(lineStart+pre.length);
        newCursor=Math.max(s-pre.length,lineStart);
      } else {
        newVal=val.slice(0,lineStart)+pre+val.slice(lineStart);
        newCursor=s+pre.length;
      }
      flushSync(()=>setDraftB(newVal));
      ta.focus(); ta.setSelectionRange(newCursor,newCursor);
    } else {
      const sel=val.slice(s,e);
      const newVal=val.slice(0,s)+pre+sel+post+val.slice(e);
      flushSync(()=>setDraftB(newVal));
      const ns=s+pre.length;
      const ne=ns+sel.length;
      ta.focus(); ta.setSelectionRange(ns,ne);
    }
  };

  const mutNote=(id:number,patch:Partial<Note>)=>setNotes(p=>p.map(n=>n.id===id?{...n,...patch}:n));

  const base = notes.filter(n=>{
    if(tab==="all")     return !n.archived&&!n.trashed;
    if(tab==="archive") return  n.archived&&!n.trashed;
    return n.trashed;
  }).filter(n=>!search||
    n.title.toLowerCase().includes(search.toLowerCase())||
    n.body.toLowerCase().includes(search.toLowerCase())
  );

  const sorted = [...base].sort((a,b)=>{
    if(sort==="created") return b.id - a.id;
    if(sort==="updated") return b.updatedAt.getTime() - a.updatedAt.getTime();
    return 0; // default: keep insertion order
  });

  const pinned   = sorted.filter(n=>n.pinned);
  const unpinned = sorted.filter(n=>!n.pinned);
  const cols     = isMobile?1:isTablet?2:3;
  const editorOpen = creating||editing!==null;

  return (
    <div style={{
      fontFamily:"'Manrope','Inter',sans-serif",
      background:theme.bg,
      minHeight:"100vh",position:"relative",overflow:"hidden",
      fontSize:"1rem",
    }}>
      <style>{CSS}</style>

      {/* Orbs */}
      <div style={{position:"absolute",inset:0,pointerEvents:"none",overflow:"hidden"}}>
        {theme.orbs.map((o,i)=>(
          <div key={i} style={{
            position:"absolute",
            top:`calc(${o.top} - ${scrollY*(0.07+i*0.05)}px)`,
            left:o.left,width:o.size,height:o.size,borderRadius:"50%",
            background:`radial-gradient(circle,${o.color} 0%,transparent 68%)`,
            filter:"blur(2px)",transition:"top 0.12s linear",
          }}/>
        ))}
      </div>

      <div style={{
        position:"relative",zIndex:10,
        maxWidth:isMobile?"100%":isTablet?920:1220,
        margin:"0 auto",
        height:"100vh",
        /* No padding here — children handle their own horizontal padding */
      }}>
        {screen==="settings"?(
          <div style={{
            position:"absolute",inset:0,overflowY:"auto",
            padding:isMobile?"0 16px":isTablet?"0 28px":"0 44px",
          }}>
          <SettingsScreen
            themeId={themeId} setThemeId={setThemeId}
            onBack={()=>setScreen("dashboard")}
            currentUser={currentUser}
            onLogin={handleLogin}
            onLogout={handleLogout}
          />
          </div>
        ):(
          <>
            {/* Search bar floats above scroll area — cards slide under it */}
            <div style={{position:"absolute",top:0,left:0,right:0,zIndex:30,
              padding:isMobile?"0 16px":isTablet?"0 28px":"0 44px",
              maxWidth:isMobile?"100%":isTablet?920:1220,margin:"0 auto",
              width:"100%",
            }}>
              <KeepSearchBar
                search={search} setSearch={setSearch}
                isMobile={isMobile}
                sort={sort}
                onSort={()=>setShowSort(true)}
                onSettings={()=>setScreen("settings")}
              />
            </div>

            {/* Scroll container fills full height; paddingTop clears the search bar */}
            <div
              className="scroll-host"
              style={{
                position:"absolute",inset:0,overflowY:"auto",
                padding:`92px 8px 150px`,
                paddingLeft:isMobile?24:isTablet?36:52,
                paddingRight:isMobile?24:isTablet?36:52,
              }}
              onScroll={e=>setScrollY((e.target as HTMLDivElement).scrollTop)}
            >
              {base.length===0?(
                <EmptyState tab={tab} search={search}/>
              ):(
                <GridView
                  pinned={pinned} unpinned={unpinned} cols={cols}
                  theme={theme} isMobile={isMobile} isTablet={isTablet} tab={tab}
                  onOpen={openEdit}
                  onPin={n=>mutNote(n.id,{pinned:!n.pinned})}
                  onArchive={n=>mutNote(n.id,{archived:!n.archived})}
                  onTrash={n=>mutNote(n.id,{trashed:!n.trashed,archived:false})}
                  onReminder={n=>setReminderNoteId(n.id)}
                />
              )}
            </div>

            <BottomNav tab={tab} setTab={setTab} isMobile={isMobile}/>
          </>
        )}
      </div>

      {/* FAB — fixed bottom-right like Google Keep */}
      {screen==="dashboard"&&<FabBtn onClick={openNew} isMobile={isMobile}/>}

      {/* Sort sheet */}
      {showSort&&(
        <SortSheet
          current={sort}
          onSelect={o=>{ setSort(o); setShowSort(false); }}
          onClose={()=>setShowSort(false)}
        />
      )}

      {/* Reminder picker */}
      {reminderNoteId!==null&&(()=>{
        const n=notes.find(x=>x.id===reminderNoteId);
        if(!n)return null;
        return(
          <ReminderModal
            note={n}
            onSave={d=>{ mutNote(n.id,{reminder:d}); setReminderNoteId(null); }}
            onClose={()=>setReminderNoteId(null)}
          />
        );
      })()}

      {editorOpen&&(
        <EditorModal
          creating={creating} title={draftT} body={draftB}
          onTitle={setDraftT} onBody={setDraftB}
          bodyRef={bodyRef} selRef={selRef}
          onClose={closeEd} onSave={save} onFmt={insertFmt}
          isMobile={isMobile} isTablet={isTablet}
        />
      )}
    </div>
  );
}

/* ════════════════════════════════════════════════════════════════════
   SEARCH BAR
   ════════════════════════════════════════════════════════════════════ */
function KeepSearchBar({search,setSearch,isMobile,sort,onSort,onSettings}:{
  search:string; setSearch:(v:string)=>void;
  isMobile:boolean; sort:SortOrder;
  onSort:()=>void; onSettings:()=>void;
}){
  const sortActive = sort !== "default";
  return (
    <div style={{
      paddingTop:20,paddingBottom:24,
      background:"linear-gradient(to bottom, rgba(0,0,0,0.38) 60%, transparent 100%)",
    }}>
      <div
        className="search-bar"
        style={{
          ...glassBase(20),borderRadius:50,
          display:"flex",alignItems:"center",gap:4,
          padding:"0 12px 0 16px",height:52,
          transition:"border-color 0.2s,box-shadow 0.2s",
        }}
      >
        <input
          value={search} onChange={e=>setSearch(e.target.value)}
          placeholder="Поиск по заметкам…"
          style={{
            flex:1,background:"transparent",border:"none",outline:"none",
            fontSize:"0.95rem",color:G.textPrimary,fontFamily:"inherit",letterSpacing:"0.01em",
          }}
        />

        {search&&(
          <button onClick={()=>setSearch("")} style={{background:"none",border:"none",cursor:"pointer",lineHeight:0,padding:6}}>
            <X size={16} color={G.textMuted}/>
          </button>
        )}

        {/* Sort button — amber tint when active */}
        <button
          className="icon-btn"
          onClick={onSort}
          title="Сортировка"
          style={{
            position:"relative",
            background:sortActive?"rgba(255,200,60,0.12)":"transparent",
            borderRadius:50,
            outline:sortActive?`1px solid rgba(255,200,60,0.30)`:"none",
          }}
        >
          <SlidersHorizontal size={17} color={sortActive?"rgba(255,210,70,0.90)":G.textSecondary}/>
          {sortActive&&(
            <span style={{
              position:"absolute",top:4,right:4,width:6,height:6,borderRadius:"50%",
              background:"rgba(255,200,60,0.90)",
            }}/>
          )}
        </button>

        <button className="icon-btn" onClick={onSettings}>
          <Settings size={18} color={G.textSecondary}/>
        </button>
      </div>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════════════
   GRID / MASONRY VIEWS
   ════════════════════════════════════════════════════════════════════ */
type ViewProps = {
  pinned:Note[];unpinned:Note[];cols:number;theme:Theme;
  isMobile:boolean;isTablet:boolean;tab:Tab;
  onOpen:(n:Note)=>void;onPin:(n:Note)=>void;
  onArchive:(n:Note)=>void;onTrash:(n:Note)=>void;
  onReminder:(n:Note)=>void;
  masonry?:boolean;
};

function GridView(p:ViewProps){
  const cp={...p};
  const g=(items:Note[])=>(
    <div style={{display:"grid",gridTemplateColumns:`repeat(${p.cols},1fr)`,gap:p.isMobile?14:18}}>
      {items.map(n=><NoteCard key={n.id} note={n} {...cp}/>)}
    </div>
  );
  return(
    <div style={{paddingTop:4}}>
      {p.pinned.length>0&&<><p className="section-label">Закреплённые</p>{g(p.pinned)}<p className="section-label" style={{marginTop:24}}>Остальные</p></>}
      {g(p.unpinned)}
    </div>
  );
}

function MasonryView(p:ViewProps){
  const cp={...p,masonry:true};
  const m=(items:Note[])=>(
    <div className="masonry" style={{"--cols":p.cols} as React.CSSProperties}>
      {items.map(n=><NoteCard key={n.id} note={n} {...cp}/>)}
    </div>
  );
  return(
    <div style={{paddingTop:4}}>
      {p.pinned.length>0&&<><p className="section-label">Закреплённые</p>{m(p.pinned)}<p className="section-label" style={{marginTop:24}}>Остальные</p></>}
      {m(p.unpinned)}
    </div>
  );
}

/* ════════════════════════════════════════════════════════════════════
   NOTE CARD
   ════════════════════════════════════════════════════════════════════ */
function NoteCard({note,theme,isMobile,isTablet,tab,masonry,onOpen,onPin,onArchive,onTrash,onReminder}:ViewProps&{note:Note}){
  const accent   = theme.accents[note.accentIdx%theme.accents.length];
  const minH     = masonry?0:isMobile?130:isTablet?140:160;
  const pad      = isMobile?"14px 16px 12px":"18px 20px 14px";
  const hasReminder = !!note.reminder;

  return(
    <div className="card" onClick={()=>onOpen(note)}>
      <div className="card-glass" style={{minHeight:minH}}>
        <div className="glass-ring"/>
        <div className="glass-sheen"/>
        <div className="card-accent" style={{background:`linear-gradient(145deg,${accent} 0%,rgba(255,255,255,0.01) 70%)`}}/>
        <div style={{position:"relative",zIndex:20,padding:pad,minHeight:minH,display:"flex",flexDirection:"column"}}>

          <div style={{display:"flex",alignItems:"flex-start",justifyContent:"space-between",gap:8,marginBottom:8}}>
            <h3 style={{margin:0,fontWeight:700,fontSize:isMobile?"0.90rem":isTablet?"0.96rem":"1.06rem",
              lineHeight:1.3,color:G.textPrimary,letterSpacing:"-0.02em",flex:1}}>
              {note.title}
            </h3>
            <button
              className={`card-pin${note.pinned?" pinned":""}`}
              onClick={e=>{e.stopPropagation();onPin(note);}}
              title={note.pinned?"Открепить":"Закрепить"}
              style={{background:"none",border:"none",cursor:"pointer",padding:2,flexShrink:0,lineHeight:0}}
            >
              {note.pinned
                ?<PinOff size={14} color="rgba(255,255,255,0.70)" strokeWidth={1.8}/>
                :<Pin    size={14} color={G.textSecondary}         strokeWidth={1.8}/>}
            </button>
          </div>

          <p style={{
            margin:"0 0 auto",
            fontSize:isMobile?"0.76rem":isTablet?"0.80rem":"0.84rem",
            color:G.textSecondary,lineHeight:1.65,fontWeight:400,whiteSpace:"pre-line",
            ...(masonry?{}:{display:"-webkit-box",WebkitLineClamp:3,WebkitBoxOrient:"vertical",overflow:"hidden"}),
            paddingBottom:12,
          }}>
            {note.body}
          </p>

          {/* Reminder badge — always visible when set */}
          {hasReminder&&(
            <button
              onClick={e=>{e.stopPropagation();onReminder(note);}}
              style={{
                alignSelf:"flex-start",display:"flex",alignItems:"center",gap:5,
                background:"rgba(255,200,60,0.12)",border:"1px solid rgba(255,200,60,0.28)",
                borderRadius:8,padding:"3px 8px 3px 6px",marginBottom:8,cursor:"pointer",
                color:"rgba(255,210,80,0.90)",fontSize:"0.68rem",fontWeight:600,fontFamily:"inherit",
                transition:"background 0.18s",
              }}
              onMouseEnter={e=>(e.currentTarget as HTMLElement).style.background="rgba(255,200,60,0.20)"}
              onMouseLeave={e=>(e.currentTarget as HTMLElement).style.background="rgba(255,200,60,0.12)"}
            >
              <BellRing size={10} strokeWidth={2}/>
              {note.reminder!.toLocaleString("ru-RU",{day:"numeric",month:"short",hour:"2-digit",minute:"2-digit"})}
            </button>
          )}

          <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",marginTop:"auto"}}>
            <div style={{display:"flex",alignItems:"center",gap:4,color:G.textMuted,fontSize:"0.68rem"}}>
              <Clock size={9} strokeWidth={1.8}/>
              <span>{fmtDate(note.updatedAt)}</span>
            </div>
            <div
              className={`card-actions${isMobile?" actions-always":""}`}
              style={{display:"flex",gap:4}}
              onClick={e=>e.stopPropagation()}
            >
              <MiniAction onClick={()=>onReminder(note)} title="Напоминание">
                <Bell size={11} color={hasReminder?"rgba(255,200,60,0.80)":G.textSecondary} strokeWidth={1.8}/>
              </MiniAction>
              {tab!=="archive"&&(
                <MiniAction onClick={()=>onArchive(note)} title="Архивировать">
                  <Archive size={11} color={G.textSecondary} strokeWidth={1.8}/>
                </MiniAction>
              )}
              <MiniAction onClick={()=>onTrash(note)} title="Удалить">
                <Trash2 size={11} color={G.textSecondary} strokeWidth={1.8}/>
              </MiniAction>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function MiniAction({children,onClick,title}:{children:React.ReactNode;onClick:()=>void;title:string}){
  return(
    <button onClick={onClick} title={title} style={{
      ...glassBase(10),width:26,height:26,borderRadius:8,
      border:"none",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",
    }}>
      {children}
    </button>
  );
}

/* ════════════════════════════════════════════════════════════════════
   EMPTY STATE
   ════════════════════════════════════════════════════════════════════ */
function EmptyState({tab,search}:{tab:Tab;search:string}){
  return(
    <div style={{display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",height:260,gap:14}}>
      <div style={{...glassBase(16),width:52,height:52,borderRadius:14,display:"flex",alignItems:"center",justifyContent:"center"}}>
        <FileText size={22} color={G.textMuted}/>
      </div>
      <p style={{color:G.textMuted,fontSize:"0.84rem",letterSpacing:"0.02em",margin:0}}>
        {search?"Ничего не найдено":tab==="all"?"Заметок пока нет":tab==="archive"?"Архив пуст":"Корзина пуста"}
      </p>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════════════
   BOTTOM NAV
   ════════════════════════════════════════════════════════════════════ */
function BottomNav({tab,setTab,isMobile}:{tab:Tab;setTab:(t:Tab)=>void;isMobile:boolean}){
  const items:[Tab,typeof FileText,string][]=[
    ["all",FileText,"Заметки"],["archive",Archive,"Архив"],["trash",Trash2,"Корзина"],
  ];
  return(
    <div style={{position:"absolute",bottom:24,left:"50%",transform:"translateX(-50%)",width:isMobile?"calc(100% - 32px)":"56%",minWidth:260,maxWidth:420}}>
      <div style={{...glassBase(28),borderRadius:30,padding:"10px 8px",
        display:"flex",alignItems:"center",justifyContent:"space-around",position:"relative"}}>
        <div style={{position:"absolute",inset:0,borderRadius:"inherit",pointerEvents:"none",zIndex:10,padding:1,
          background:"linear-gradient(160deg,rgba(255,255,255,0.28) 0%,rgba(255,255,255,0.04) 60%)",
          WebkitMask:"linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0)",
          WebkitMaskComposite:"xor",maskComposite:"exclude"}}/>
        {items.map(([id,Icon,label])=>{
          const active=tab===id;
          return(
            <button key={id} onClick={()=>setTab(id)} style={{
              display:"flex",flexDirection:"column",alignItems:"center",gap:4,
              padding:"4px 20px",borderRadius:20,border:"none",cursor:"pointer",
              background:"transparent",fontFamily:"inherit",
              color:active?G.textPrimary:G.textMuted,position:"relative",transition:"color 0.2s",
            }}>
              <Icon size={20} strokeWidth={active?2.2:1.5}/>
              {active&&<div style={{position:"absolute",bottom:-2,left:"50%",transform:"translateX(-50%)",width:18,height:2,borderRadius:2,background:"rgba(255,255,255,0.70)"}}/>}
            </button>
          );
        })}
      </div>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════════════
   FAB
   ════════════════════════════════════════════════════════════════════ */
function FabBtn({onClick,isMobile}:{onClick:()=>void;isMobile:boolean}){
  const sz=isMobile?52:56;
  return(
    <button onClick={onClick} style={{
      ...glassBase(16),
      position:"fixed",
      bottom:isMobile?88:32,
      right:isMobile?20:32,
      width:sz,height:sz,
      borderRadius:16,border:"none",cursor:"pointer",
      display:"flex",alignItems:"center",justifyContent:"center",
      background:G.bgHov,
      zIndex:40,
      transition:"transform 0.22s cubic-bezier(0.34,1.56,0.64,1),background 0.2s,box-shadow 0.2s",
    }}
    onMouseEnter={e=>{const el=e.currentTarget as HTMLElement;el.style.transform="scale(1.12)";el.style.background="rgba(255,255,255,0.16)";el.style.boxShadow="0 20px 60px rgba(0,0,0,0.60),inset 0 1px 0 rgba(255,255,255,0.25)";}}
    onMouseLeave={e=>{const el=e.currentTarget as HTMLElement;el.style.transform="scale(1)";el.style.background=G.bgHov;el.style.boxShadow=G.shadow;}}
    >
      <Plus size={isMobile?22:24} color={G.textPrimary} strokeWidth={2}/>
    </button>
  );
}

/* ════════════════════════════════════════════════════════════════════
   SORT SHEET
   ════════════════════════════════════════════════════════════════════ */
const SORT_OPTIONS: { id: SortOrder; label: string; sub: string; Icon: typeof Shuffle }[] = [
  { id:"default", label:"По умолчанию",   sub:"Порядок добавления",     Icon:Shuffle      },
  { id:"created", label:"Дата создания",  sub:"Сначала новые",          Icon:CalendarDays },
  { id:"updated", label:"Дата изменения", sub:"Недавно отредактированные", Icon:RefreshCw },
];

function SortSheet({current,onSelect,onClose}:{
  current:SortOrder; onSelect:(o:SortOrder)=>void; onClose:()=>void;
}){
  return(
    <div
      style={{position:"fixed",inset:0,zIndex:60,display:"flex",flexDirection:"column",justifyContent:"flex-end"}}
      onClick={e=>{if(e.target===e.currentTarget)onClose();}}
    >
      {/* Backdrop */}
      <div style={{position:"absolute",inset:0,background:"rgba(0,0,0,0.52)",backdropFilter:"blur(3px)"}} onClick={onClose}/>

      {/* Sheet */}
      <div className="sheet-in" style={{
        position:"relative",zIndex:1,
        background:"rgba(18,18,24,0.96)",
        backdropFilter:"blur(40px)",WebkitBackdropFilter:"blur(40px)",
        borderTop:"1px solid rgba(255,255,255,0.14)",
        borderRadius:"24px 24px 0 0",
        boxShadow:"0 -16px 60px rgba(0,0,0,0.60), inset 0 1px 0 rgba(255,255,255,0.12)",
        padding:"0 0 env(safe-area-inset-bottom,16px)",
      }}>
        {/* Drag handle */}
        <div style={{display:"flex",justifyContent:"center",padding:"12px 0 4px"}}>
          <div style={{width:36,height:4,borderRadius:2,background:"rgba(255,255,255,0.18)"}}/>
        </div>

        {/* Title */}
        <div style={{padding:"8px 24px 16px",display:"flex",alignItems:"center",gap:10,borderBottom:"1px solid rgba(255,255,255,0.06)"}}>
          <SlidersHorizontal size={16} color={G.textMuted}/>
          <span style={{fontWeight:700,fontSize:"0.96rem",color:G.textPrimary,letterSpacing:"-0.01em"}}>Сортировка</span>
        </div>

        {/* Options */}
        <div style={{padding:"8px 12px 20px",display:"flex",flexDirection:"column",gap:4}}>
          {SORT_OPTIONS.map(({id,label,sub,Icon})=>{
            const active = current===id;
            return(
              <button key={id} onClick={()=>onSelect(id)} style={{
                display:"flex",alignItems:"center",gap:14,padding:"14px 16px",
                borderRadius:16,border:"none",cursor:"pointer",fontFamily:"inherit",
                background:active?"rgba(255,255,255,0.07)":"transparent",
                transition:"background 0.16s",textAlign:"left",
              }}
              onMouseEnter={e=>(e.currentTarget as HTMLElement).style.background="rgba(255,255,255,0.06)"}
              onMouseLeave={e=>(e.currentTarget as HTMLElement).style.background=active?"rgba(255,255,255,0.07)":"transparent"}
              >
                <div style={{
                  width:40,height:40,borderRadius:12,flexShrink:0,
                  background:active?"rgba(255,255,255,0.10)":"rgba(255,255,255,0.05)",
                  border:`1px solid ${active?"rgba(255,255,255,0.20)":G.border}`,
                  display:"flex",alignItems:"center",justifyContent:"center",
                  transition:"all 0.16s",
                }}>
                  <Icon size={18} color={active?G.textPrimary:G.textSecondary} strokeWidth={1.7}/>
                </div>
                <div style={{flex:1}}>
                  <p style={{margin:0,fontWeight:active?700:500,fontSize:"0.92rem",color:active?G.textPrimary:G.textSecondary}}>{label}</p>
                  <p style={{margin:"2px 0 0",fontSize:"0.74rem",color:G.textMuted}}>{sub}</p>
                </div>
                {active&&(
                  <div style={{
                    width:22,height:22,borderRadius:"50%",flexShrink:0,
                    background:"rgba(255,255,255,0.90)",
                    display:"flex",alignItems:"center",justifyContent:"center",
                  }}>
                    <Check size={12} color="#111" strokeWidth={2.5}/>
                  </div>
                )}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════════════
   REMINDER MODAL
   ════════════════════════════════════════════════════════════════════ */
function ReminderModal({note,onSave,onClose}:{
  note:Note; onSave:(d:Date|null)=>void; onClose:()=>void;
}){
  const now   = new Date();
  const pad   = (n:number)=>String(n).padStart(2,"0");
  const toVal = (d:Date)=>`${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;

  const [val, setVal] = useState(note.reminder?toVal(note.reminder):"");

  const todayAt=(h:number,m=0)=>{
    const d=new Date(now);d.setHours(h,m,0,0);
    if(d<=now){d.setDate(d.getDate()+1);}
    return d;
  };
  const tomorrowAt=(h:number)=>{const d=new Date(now);d.setDate(d.getDate()+1);d.setHours(h,0,0,0);return d;};
  const nextMonday=()=>{const d=new Date(now);const diff=(8-d.getDay())%7||7;d.setDate(d.getDate()+diff);d.setHours(8,0,0,0);return d;};

  const quickPicks=[
    {label:"Сегодня",       sub:"20:00",  val:todayAt(20)},
    {label:"Завтра утром",  sub:"08:00",  val:tomorrowAt(8)},
    {label:"Следующая неделя", sub:"Пн 08:00", val:nextMonday()},
  ];

  const fmt=(d:Date)=>d.toLocaleString("ru-RU",{day:"numeric",month:"long",hour:"2-digit",minute:"2-digit"});

  return(
    <div
      style={{position:"fixed",inset:0,zIndex:60,display:"flex",alignItems:"center",justifyContent:"center",
        background:"rgba(0,0,0,0.55)",backdropFilter:"blur(4px)",padding:24}}
      onClick={e=>{if(e.target===e.currentTarget)onClose();}}
    >
      <div className="modal-in" style={{
        ...glassBase(32),width:"100%",maxWidth:360,
        border:"1px solid rgba(255,255,255,0.26)",
        boxShadow:"0 32px 80px rgba(0,0,0,0.65),inset 0 1px 0 rgba(255,255,255,0.22)",
        borderRadius:24,overflow:"hidden",position:"relative",
      }}>
        {/* ring */}
        <div style={{position:"absolute",inset:0,borderRadius:"inherit",pointerEvents:"none",zIndex:1,padding:1,
          background:"linear-gradient(160deg,rgba(255,255,255,0.38) 0%,rgba(255,255,255,0.05) 50%,transparent 100%)",
          WebkitMask:"linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0)",
          WebkitMaskComposite:"xor",maskComposite:"exclude"}}/>

        <div style={{position:"relative",zIndex:2,padding:"22px 22px 20px"}}>
          {/* Header */}
          <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",marginBottom:20}}>
            <div style={{display:"flex",alignItems:"center",gap:10}}>
              <CalendarClock size={18} color="rgba(255,200,60,0.90)"/>
              <span style={{fontWeight:700,fontSize:"1rem",color:G.textPrimary}}>Напоминание</span>
            </div>
            <button onClick={onClose} style={{background:"none",border:"none",cursor:"pointer",lineHeight:0,padding:4}}>
              <X size={16} color={G.textMuted}/>
            </button>
          </div>

          {/* Quick picks */}
          <div style={{display:"flex",flexDirection:"column",gap:8,marginBottom:18}}>
            {quickPicks.map(qp=>(
              <button key={qp.label} onClick={()=>setVal(toVal(qp.val))} style={{
                display:"flex",alignItems:"center",justifyContent:"space-between",
                padding:"11px 14px",borderRadius:14,border:`1px solid ${G.border}`,
                background:val===toVal(qp.val)?"rgba(255,200,60,0.12)":G.bg,
                cursor:"pointer",fontFamily:"inherit",transition:"all 0.18s",
                outline:val===toVal(qp.val)?"1px solid rgba(255,200,60,0.35)":"none",
              }}
              onMouseEnter={e=>(e.currentTarget as HTMLElement).style.background="rgba(255,255,255,0.08)"}
              onMouseLeave={e=>(e.currentTarget as HTMLElement).style.background=val===toVal(qp.val)?"rgba(255,200,60,0.12)":G.bg}
              >
                <span style={{fontWeight:600,fontSize:"0.86rem",color:G.textPrimary}}>{qp.label}</span>
                <span style={{fontSize:"0.76rem",color:G.textSecondary}}>{fmt(qp.val)}</span>
              </button>
            ))}
          </div>

          {/* Custom datetime */}
          <div style={{marginBottom:18}}>
            <p style={{margin:"0 0 8px",fontSize:"0.68rem",fontWeight:600,color:G.textMuted,
              textTransform:"uppercase",letterSpacing:"0.08em"}}>Своя дата и время</p>
            <input
              type="datetime-local" value={val}
              min={toVal(new Date(now.getTime()+60000))}
              onChange={e=>setVal(e.target.value)}
              style={{
                width:"100%",background:"rgba(255,255,255,0.05)",
                border:`1px solid ${G.border}`,borderRadius:12,
                padding:"10px 14px",outline:"none",fontFamily:"inherit",
                fontSize:"0.86rem",color:G.textPrimary,colorScheme:"dark",
              }}
            />
          </div>

          {/* Actions */}
          <div style={{display:"flex",gap:8}}>
            {note.reminder&&(
              <button onClick={()=>onSave(null)} style={{
                flex:1,padding:"11px 0",borderRadius:14,border:`1px solid rgba(255,100,100,0.28)`,
                background:"rgba(255,80,80,0.08)",cursor:"pointer",fontFamily:"inherit",
                fontSize:"0.84rem",fontWeight:600,color:"rgba(255,120,120,0.90)",transition:"all 0.18s",
              }}>Удалить</button>
            )}
            <button
              onClick={()=>{if(val)onSave(new Date(val));}}
              disabled={!val}
              style={{
                flex:2,padding:"11px 0",borderRadius:14,border:"1px solid rgba(255,200,60,0.35)",
                background:val?"rgba(255,200,60,0.14)":"rgba(255,255,255,0.04)",
                cursor:val?"pointer":"not-allowed",fontFamily:"inherit",
                fontSize:"0.84rem",fontWeight:700,
                color:val?"rgba(255,210,80,0.95)":G.textMuted,transition:"all 0.18s",
              }}
            >Сохранить</button>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════════════
   SETTINGS
   ════════════════════════════════════════════════════════════════════ */
function SettingsScreen({themeId,setThemeId,onBack,currentUser,onLogin,onLogout}:{
  themeId:ThemeId;setThemeId:(id:ThemeId)=>void;
  onBack:()=>void;
  currentUser:AuthUser|null;
  onLogin:(u:AuthUser)=>void;
  onLogout:()=>void;
}){
  return(
    <div style={{paddingBottom:64}}>
      <div style={{display:"flex",alignItems:"center",gap:14,paddingTop:28,paddingBottom:28}}>
        <button onClick={onBack} style={{...glassBase(16),width:38,height:38,borderRadius:12,border:"none",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center"}}>
          <ChevronLeft size={18} color={G.textSecondary}/>
        </button>
        <h1 style={{fontWeight:700,fontSize:"1.3rem",color:G.textPrimary,margin:0,letterSpacing:"-0.02em"}}>Настройки</h1>
      </div>

      {/* ── Account ── */}
      <SLabel Icon={User} label="Аккаунт"/>
      <div style={{marginBottom:36}}>
        {currentUser
          ? <AccountCard user={currentUser} onLogout={onLogout}/>
          : <AuthPanel onLogin={onLogin}/>
        }
      </div>

      {/* ── Themes ── */}
      <SLabel Icon={Palette} label="Цветовая тема"/>
      <div style={{display:"flex",flexWrap:"wrap",gap:10,marginBottom:36}}>
        {THEMES.map(t=>{
          const active=t.id===themeId;
          return(
            <button key={t.id} onClick={()=>setThemeId(t.id)} style={{
              ...glassBase(20),padding:0,
              border:active?`1px solid rgba(255,255,255,0.50)`:`1px solid ${G.border}`,
              boxShadow:active?"0 16px 48px rgba(0,0,0,0.55),inset 0 1px 0 rgba(255,255,255,0.28)":G.shadow,
              cursor:"pointer",borderRadius:18,overflow:"hidden",transition:"all 0.25s",
            }}>
              <div style={{height:56,background:t.bg,position:"relative",overflow:"hidden"}}>
                {t.orbs.slice(0,2).map((o,i)=>(
                  <div key={i} style={{position:"absolute",top:i===0?"-30%":"20%",left:i===0?"-10%":"52%",
                    width:o.size*0.3,height:o.size*0.3,borderRadius:"50%",
                    background:`radial-gradient(circle,${o.color} 0%,transparent 70%)`}}/>
                ))}
                {active&&<div style={{position:"absolute",top:8,right:8,width:20,height:20,borderRadius:"50%",
                  background:"rgba(255,255,255,0.90)",display:"flex",alignItems:"center",justifyContent:"center"}}>
                  <Check size={12} color="#111" strokeWidth={2.5}/>
                </div>}
              </div>
              <div style={{padding:"10px 14px 12px",display:"flex",alignItems:"center",justifyContent:"center"}}>
                <span style={{fontSize:"1.25rem"}}>{t.emoji}</span>
              </div>
            </button>
          );
        })}
      </div>

  );
}

/* ── Logged-in account card ── */
function AccountCard({user,onLogout}:{user:AuthUser;onLogout:()=>void}){
  return(
    <div style={{...glassBase(20),padding:"18px 20px",display:"flex",alignItems:"center",gap:16,borderRadius:18}}>
      <div style={{width:44,height:44,borderRadius:"50%",background:"rgba(255,255,255,0.12)",
        border:`1px solid ${G.border}`,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
        <User size={20} color={G.textPrimary} strokeWidth={1.5}/>
      </div>
      <div style={{flex:1,minWidth:0}}>
        <p style={{margin:0,fontWeight:700,fontSize:"0.92rem",color:G.textPrimary,
          overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>{user.name}</p>
        <p style={{margin:"2px 0 0",fontSize:"0.74rem",color:G.textMuted,
          overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>{user.email}</p>
      </div>
      <div style={{display:"flex",alignItems:"center",gap:6,flexShrink:0,
        fontSize:"0.68rem",color:G.textMuted,background:"rgba(0,200,80,0.10)",
        border:"1px solid rgba(0,200,80,0.20)",borderRadius:8,padding:"4px 8px"}}>
        <Shield size={10} color="rgba(0,220,100,0.80)"/>
        <span style={{color:"rgba(0,220,100,0.80)"}}>Синхронизировано</span>
      </div>
      <button onClick={onLogout} title="Выйти" style={{
        ...glassBase(12),width:36,height:36,borderRadius:10,border:"none",cursor:"pointer",
        display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0,
      }}>
        <LogOut size={15} color={G.textSecondary}/>
      </button>
    </div>
  );
}

/* ── Auth panel (login / register) ── */
function AuthPanel({onLogin}:{onLogin:(u:AuthUser)=>void}){
  const [mode,   setMode]   = useState<"login"|"register">("login");
  const [name,   setName]   = useState("");
  const [email,  setEmail]  = useState("");
  const [pw,     setPw]     = useState("");
  const [showPw, setShowPw] = useState(false);
  const [err,    setErr]    = useState("");
  const [ok,     setOk]     = useState(false);

  const submit = () => {
    setErr(""); setOk(false);
    if (mode === "register") {
      const e = authRegister(email, name, pw);
      if (e) { setErr(e); return; }
      setOk(true);
      setTimeout(()=>onLogin({ email: email.trim().toLowerCase(), name: name.trim() }), 600);
    } else {
      const e = authLogin(email, pw);
      if (e) { setErr(e); return; }
      const me = authGetMe()!;
      onLogin(me);
    }
  };

  const inputStyle: React.CSSProperties = {
    width:"100%",background:"rgba(255,255,255,0.04)",border:`1px solid ${G.border}`,
    borderRadius:12,padding:"11px 14px",outline:"none",fontFamily:"inherit",
    fontSize:"0.88rem",color:G.textPrimary,transition:"border-color 0.2s",
  };

  return(
    <div style={{...glassBase(20),padding:"22px 24px",borderRadius:20}}>
      {/* Tab row */}
      <div style={{display:"flex",gap:8,marginBottom:22}}>
        {(["login","register"] as const).map(m=>(
          <button key={m} onClick={()=>{setMode(m);setErr("");setOk(false);}} style={{
            flex:1,padding:"9px 0",borderRadius:12,border:"none",cursor:"pointer",
            fontFamily:"inherit",fontSize:"0.82rem",fontWeight:600,transition:"all 0.2s",
            background:mode===m?G.bgHov:"transparent",
            color:mode===m?G.textPrimary:G.textMuted,
            boxShadow:mode===m?G.shadow:"none",
            outline:mode===m?`1px solid ${G.border}`:"none",
          }}>
            {m==="login"?"Войти":"Создать аккаунт"}
          </button>
        ))}
      </div>

      <div style={{display:"flex",flexDirection:"column",gap:12}}>
        {mode==="register"&&(
          <input
            value={name} onChange={e=>setName(e.target.value)}
            placeholder="Имя"
            style={inputStyle}
            onFocus={e=>(e.target.style.borderColor="rgba(255,255,255,0.40)")}
            onBlur={e=>(e.target.style.borderColor=G.border)}
          />
        )}
        <input
          value={email} onChange={e=>setEmail(e.target.value)}
          placeholder="Email" type="email"
          style={inputStyle}
          onFocus={e=>(e.target.style.borderColor="rgba(255,255,255,0.40)")}
          onBlur={e=>(e.target.style.borderColor=G.border)}
          onKeyDown={e=>e.key==="Enter"&&submit()}
        />
        <div style={{position:"relative"}}>
          <input
            value={pw} onChange={e=>setPw(e.target.value)}
            placeholder="Пароль" type={showPw?"text":"password"}
            style={{...inputStyle,paddingRight:42}}
            onFocus={e=>(e.target.style.borderColor="rgba(255,255,255,0.40)")}
            onBlur={e=>(e.target.style.borderColor=G.border)}
            onKeyDown={e=>e.key==="Enter"&&submit()}
          />
          <button
            onMouseDown={e=>e.preventDefault()}
            onClick={()=>setShowPw(p=>!p)}
            style={{position:"absolute",right:12,top:"50%",transform:"translateY(-50%)",
              background:"none",border:"none",cursor:"pointer",lineHeight:0,padding:2}}
          >
            {showPw?<EyeOff size={16} color={G.textMuted}/>:<Eye size={16} color={G.textMuted}/>}
          </button>
        </div>

        {err&&<p style={{margin:0,fontSize:"0.78rem",color:"rgba(255,100,100,0.90)",padding:"0 2px"}}>{err}</p>}
        {ok &&<p style={{margin:0,fontSize:"0.78rem",color:"rgba(80,220,120,0.90)",padding:"0 2px"}}>Аккаунт создан! Входим…</p>}

        <button onClick={submit} style={{
          marginTop:4,padding:"12px 0",borderRadius:14,border:"none",cursor:"pointer",
          background:"rgba(255,255,255,0.12)",fontFamily:"inherit",fontSize:"0.88rem",fontWeight:700,
          color:G.textPrimary,transition:"background 0.2s,box-shadow 0.2s",
          boxShadow:"0 8px 24px rgba(0,0,0,0.30)",
        }}
        onMouseEnter={e=>{const el=e.currentTarget as HTMLElement;el.style.background="rgba(255,255,255,0.20)";}}
        onMouseLeave={e=>{const el=e.currentTarget as HTMLElement;el.style.background="rgba(255,255,255,0.12)";}}
        >
          {mode==="login"?"Войти":"Зарегистрироваться"}
        </button>
      </div>

      <p style={{margin:"14px 0 0",fontSize:"0.72rem",color:G.textMuted,textAlign:"center",lineHeight:1.6}}>
        Данные хранятся локально в вашем браузере.<br/>Заметки автоматически синхронизируются между сессиями.
      </p>
    </div>
  );
}

function SLabel({Icon,label}:{Icon:React.FC<{size?:number;color?:string}>;label:string}){
  return(
    <div style={{display:"flex",alignItems:"center",gap:8,marginBottom:12}}>
      <Icon size={13} color={G.textMuted}/>
      <span style={{fontSize:"0.68rem",fontWeight:600,color:G.textMuted,letterSpacing:"0.08em",textTransform:"uppercase"}}>{label}</span>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════════════
   EDITOR MODAL
   ════════════════════════════════════════════════════════════════════ */
function EditorModal({creating,title,body,onTitle,onBody,bodyRef,selRef,onClose,onSave,onFmt,isMobile,isTablet}:{
  creating:boolean;title:string;body:string;
  onTitle:(v:string)=>void;onBody:(v:string)=>void;
  bodyRef:React.RefObject<HTMLTextAreaElement>;
  selRef:React.MutableRefObject<{start:number;end:number}>;
  onClose:()=>void;onSave:()=>void;
  onFmt:(pre:string,post?:string,linePrefix?:boolean)=>void;
  isMobile:boolean;isTablet:boolean;
}){
  useEffect(()=>{
    const h=(e:KeyboardEvent)=>{
      if((e.metaKey||e.ctrlKey)&&e.key==="s"){e.preventDefault();onSave();}
      if(e.key==="Escape")onClose();
    };
    window.addEventListener("keydown",h);return()=>window.removeEventListener("keydown",h);
  },[onSave,onClose]);

  const trackSel=()=>{
    const ta=bodyRef.current;if(!ta)return;
    selRef.current={start:ta.selectionStart,end:ta.selectionEnd};
  };

  const wc=body.trim().split(/\s+/).filter(Boolean).length;
  const today=new Date().toLocaleDateString("ru-RU",{day:"numeric",month:"long",year:"numeric"});
  const mW=isMobile?"100%":isTablet?"82%":"62%";
  const mH=isMobile?"100%":"88vh";
  const br=isMobile?0:G.radius+4;

  /* Format actions — onMouseDown prevents textarea blur so selRef stays valid */
  const fmtActions:[string,string,string,boolean][]=[
    ["B","**","**",false],
    ["I","_","_",false],
    ["UL","- ","",true],
    ["OL","1. ","",true],
    ["H1","# ","",true],
  ];

  return(
    <div
      style={{position:"fixed",inset:0,zIndex:50,display:"flex",alignItems:"center",justifyContent:"center",
        background:G.overlay,backdropFilter:isMobile?"none":"blur(2px)",padding:isMobile?0:24}}
      onClick={e=>{if(e.target===e.currentTarget)onClose();}}
    >
      <div className="modal-in" style={{
        ...glassBase(32),width:mW,maxWidth:isMobile?"100%":isTablet?760:720,height:mH,
        borderRadius:br,border:`1px solid rgba(255,255,255,0.28)`,
        boxShadow:"0 32px 80px rgba(0,0,0,0.65),inset 0 1px 0 rgba(255,255,255,0.22),inset 0 -1px 0 rgba(0,0,0,0.20)",
        display:"flex",flexDirection:"column",overflow:"hidden",position:"relative",
      }}>
        <div style={{position:"absolute",inset:0,borderRadius:"inherit",pointerEvents:"none",zIndex:10,padding:1,
          background:"linear-gradient(160deg,rgba(255,255,255,0.40) 0%,rgba(255,255,255,0.06) 45%,rgba(255,255,255,0.01) 100%)",
          WebkitMask:"linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0)",
          WebkitMaskComposite:"xor",maskComposite:"exclude"}}/>
        <div style={{position:"absolute",inset:0,borderRadius:"inherit",pointerEvents:"none",zIndex:9,
          background:"linear-gradient(45deg,rgba(255,255,255,0.05) 0%,transparent 55%,rgba(255,255,255,0.03) 100%)"}}/>

        <div style={{position:"relative",zIndex:20,display:"flex",flexDirection:"column",height:"100%"}}>
          {/* Header */}
          <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",padding:"14px 20px",borderBottom:`1px solid rgba(255,255,255,0.08)`}}>
            <GlassChip onClick={onClose}>
              <X size={14} color={G.textSecondary}/>
              <span style={{fontSize:"0.78rem",color:G.textSecondary,fontWeight:500}}>Закрыть</span>
            </GlassChip>
            <span style={{fontSize:"0.66rem",fontWeight:500,color:G.textMuted,letterSpacing:"0.08em",textTransform:"uppercase"}}>
              {creating?"Новая заметка":"Редактировать"}
            </span>
            <GlassChip onClick={onSave} highlight>
              <Check size={14} color={G.textPrimary}/>
              <span style={{fontSize:"0.78rem",color:G.textPrimary,fontWeight:600}}>Сохранить</span>
            </GlassChip>
          </div>

          <div style={{padding:"20px 24px 0"}}>
            <input value={title} onChange={e=>onTitle(e.target.value)} placeholder="Заголовок..." autoFocus
              style={{width:"100%",background:"transparent",border:"none",outline:"none",fontFamily:"inherit",fontWeight:300,
                fontSize:isMobile?"1.5rem":"1.75rem",letterSpacing:"-0.025em",color:G.textPrimary}}/>
          </div>

          <div style={{padding:"6px 24px 12px",display:"flex",alignItems:"center",gap:8,color:G.textMuted,fontSize:"0.68rem",borderBottom:"1px solid rgba(255,255,255,0.06)"}}>
            <Clock size={10}/><span>{today}</span>
            <span style={{opacity:0.5}}>·</span>
            <Hash size={10}/><span>{wc} слов</span>
          </div>

          <div className="scroll-host" style={{flex:1,overflowY:"auto",padding:"16px 24px"}}>
            <textarea
              ref={bodyRef} value={body}
              onChange={e=>{ onBody(e.target.value); trackSel(); }}
              onSelect={trackSel} onKeyUp={trackSel} onClick={trackSel}
              placeholder="Начните писать..."
              style={{width:"100%",minHeight:220,background:"transparent",border:"none",outline:"none",resize:"none",
                fontFamily:"'Inter',sans-serif",fontWeight:400,fontSize:"1rem",lineHeight:1.75,color:G.textSecondary}}
            />
          </div>

          {/* Format toolbar */}
          <div style={{display:"flex",alignItems:"center",gap:4,padding:"10px 20px",
            borderTop:"1px solid rgba(255,255,255,0.06)",background:"rgba(0,0,0,0.12)"}}>
            {fmtActions.map(([label,pre,post,lp])=>(
              <button
                key={label}
                className="fmt-btn"
                /* onMouseDown prevents blur so textarea keeps its selection range */
                onMouseDown={e=>e.preventDefault()}
                onClick={()=>onFmt(pre,post,lp)}
              >
                {label}
              </button>
            ))}
            <button
              className="fmt-btn"
              onMouseDown={e=>e.preventDefault()}
              onClick={()=>onFmt("[","](url)")}
              style={{display:"flex",alignItems:"center",justifyContent:"center"}}
            >
              <Link2 size={14}/>
            </button>
            <div style={{flex:1}}/>
            {!isMobile&&<span style={{fontSize:"0.63rem",color:"rgba(255,255,255,0.16)",fontFamily:"monospace"}}>⌘S · Esc</span>}
          </div>
        </div>
      </div>
    </div>
  );
}

function GlassChip({children,onClick,highlight}:{children:React.ReactNode;onClick:()=>void;highlight?:boolean}){
  return(
    <button onClick={onClick} style={{
      ...glassBase(16),display:"flex",alignItems:"center",gap:6,padding:"7px 14px",borderRadius:12,
      border:`1px solid ${highlight?"rgba(255,255,255,0.35)":G.border}`,
      background:highlight?G.bgHov:G.bg,cursor:"pointer",fontFamily:"inherit",transition:"all 0.2s",
    }}>{children}</button>
  );
}
