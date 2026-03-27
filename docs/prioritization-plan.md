# Hypership — Plano de Priorizacao

> O que fazer, em que ordem, e por que. Atualizado em 2026-03-27.

## Principio

Nao adicionar nada. Validar o que existe. Simplificar com base em dados.

---

## Fase 0: Pre-validacao (antes de usar em projetos reais)

### 0.1 Ajustar linguagem de enforcement → guidance
- [ ] README: trocar "enforces", "blocks", "hard stop" por "guides", "checks", "checkpoint"
- [ ] Skills: revisar delivery SKILL.md e removedebt SKILL.md — mesma correcao
- [ ] Specs: marcar como historicos (nao atualizar, deixar como registro de design original)
- **Por que primeiro**: se alguem instalar hoje, a expectativa precisa estar correta

### 0.2 Adicionar fast-track no Phase 0
- [ ] Delivery SKILL.md: se classificacao = chore simples ou fix trivial, pular brainstorm/plan/worktree
- [ ] Ir direto: classify → TDD → commit → log
- **Por que segundo**: sem isso, o time vai contornar o plugin na primeira tarefa pequena

### 0.3 Congelar site e scope
- [ ] Nao tocar no site ate ter dados de validacao
- [ ] Nao adicionar features ao plugin
- [ ] Foco exclusivo: usar e medir
- **Por que**: evitar acumular mais debt antes de validar

---

## Fase 1: Validacao (semana 1-4)

Seguir `docs/validation-plan.md` rigorosamente.

### Semana 1-2: Friction Log
- [ ] Usar `/delivery` em pelo menos 5 tarefas reais
- [ ] Usar `/removedebt` em pelo menos 2 sessoes reais
- [ ] Registrar friction log para cada uso
- [ ] Resultado em `docs/validation-results/week-01.md` e `week-02.md`

### Semana 2-4: Gate Effectiveness
- [ ] Registrar cada gate que dispara
- [ ] Calcular precision e recall apos 15+ entregas
- [ ] Resultado em `docs/validation-results/gate-effectiveness.md`

### Semana 3-4: Comparacao pareada
- [ ] Pelo menos 3 tarefas similares feitas com e sem Hypership
- [ ] Comparar cobertura, bugs, tempo, qualidade
- [ ] Resultado em `docs/validation-results/comparison.md`

### Pontual: Debt Scanner Accuracy
- [ ] Rodar scanner em projeto conhecido
- [ ] Comparar com debt real
- [ ] Resultado em `docs/validation-results/scanner-accuracy.md`

---

## Fase 2: Decisao (apos semana 4)

Com dados em maos, responder:

1. **O pipeline completo vale a pena?** Se sim, refinar. Se nao, extrair o que funciona.
2. **Quais gates tem precision/recall aceitavel?** Manter os bons, simplificar ou remover os ruins.
3. **O fast-track resolve a friccao de tarefas simples?** Se nao, repensar Phase 0.
4. **O debt scanner encontra debt real?** Se nao, simplificar categorias.
5. **O time contornou o plugin?** Se sim, entender por que — friccao > valor percebido.

---

## Fase 3: Refinamento (semana 5+)

Baseado nos dados da Fase 2:

- [ ] Simplificar o que nao agregou valor
- [ ] Fortalecer o que funcionou
- [ ] Atualizar README com resultados reais (nao promessas)
- [ ] Decidir futuro do site (atualizar com produto real ou descartar)
- [ ] Reavaliar dependencia do Superpowers
- [ ] Considerar se logs devem migrar de markdown para JSON/YAML

---

## Anti-patterns a evitar

- **Nao adicionar features antes de validar as existentes**
- **Nao otimizar o site antes de ter product-market fit**
- **Nao confundir "funciona na minha cabeca" com "funciona na pratica"**
- **Nao interpretar ausencia de reclamacao como validacao** — medir ativamente
