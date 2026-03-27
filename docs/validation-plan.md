# Hypership Validation Plan

> Metodologia para medir se o Hypership produz resultado melhor do que "dev senior + Superpowers direto".

## Metrica central

O pipeline Hypership produz resultado mensuravelmente melhor do que um dev senior usando Superpowers skills diretamente?

---

## 1. Friction Log (semana 1-2)

Use `/delivery` e `/removedebt` em tarefas reais. Para cada uso, registre:

```markdown
## Friction Log Entry
- Data: YYYY-MM-DD
- Comando: /delivery | /removedebt
- Tarefa: [descricao curta]
- Classificacao do Phase 0: [o que o Claude escolheu]
- Classificacao correta: [o que deveria ter sido]
- Steps que agregaram valor: [lista]
- Steps que foram friccao inutil: [lista]
- O gate pegou algo real? [sim/nao + o que]
- Tempo total vs estimativa sem Hypership: [X min vs Y min]
- Eu teria feito diferente sem o plugin? [sim/nao + como]
```

**Mede**: friccao vs valor percebido em cada step do pipeline.

---

## 2. Gate Effectiveness (semana 2-4)

Para cada gate que dispara:

```markdown
## Gate: [bug-as-test | acceptance-coverage | safety-snapshot | hard-stop]
- Disparou? [sim/nao]
- Pegou problema real? [sim/nao]
- Qual problema? [descricao]
- Falso positivo? [bloqueou sem razao?]
- Falso negativo? [deixou passar algo que deveria pegar?]
```

Depois de 15-20 entregas, calcule:
- **Precision**: dos gates que dispararam, quantos pegaram problema real?
- **Recall**: dos problemas reais que existiam, quantos o gate pegou?

Thresholds:
- Precision < 50% = gates irritam mais do que ajudam
- Recall < 50% = gates dao falsa seguranca

---

## 3. Comparacao pareada (semana 3-4)

Mesma categoria de tarefa feita de duas formas:

| | Com Hypership | Sem Hypership |
|---|---|---|
| Metodo | `/delivery add X` | Superpowers direto (brainstorm > plan > TDD) |
| Cobertura de testes | ? | ? |
| Bugs em review | ? | ? |
| Tempo total | ? | ? |
| Qualidade do codigo | ? | ? |

Resultado esperado:
- "Resultado igual mas mais rapido/seguro com Hypership" = produto validado
- "Resultado igual mas mais cerimonia" = produto nao validado

---

## 4. Debt Scanner Accuracy (pontual)

Rodar debt-scanner em projeto ja conhecido. Comparar:
- O que o scanner encontrou vs debt real conhecido
- O que perdeu (falsos negativos)
- O que chamou de debt mas nao e (falsos positivos)

---

## Registro de resultados

Resultados devem ser registrados em `docs/validation-results/` com um arquivo por semana:
- `docs/validation-results/week-01.md`
- `docs/validation-results/week-02.md`
- etc.
