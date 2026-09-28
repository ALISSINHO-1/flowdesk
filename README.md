# FlowDesk

Gerenciador visual de tarefas para organizar atividades, prioridades e prazos com clareza.

## Sobre o projeto

O FlowDesk é um MVP de produtividade desenvolvido em Flutter. Ele demonstra CRUD, estado reativo, persistência local e uma interface responsiva para web e Android. Os dados ficam no dispositivo e não há backend.

## Funcionalidades

- Dashboard com totais, tarefas por status e itens atrasados.
- Criação, visualização, edição, atualização rápida de status e exclusão confirmada.
- Busca por título e descrição, combinada com filtros de status, prioridade e prazo.
- Persistência local das tarefas em JSON e preferência de tema.
- Tema claro e escuro, navegação responsiva e estados vazios.
- Destaque discreto para tarefas vencidas.

## Tecnologias

- Flutter e Dart
- Material 3
- SharedPreferences
- Provider e ChangeNotifier

## Arquitetura

O modelo `Task` e seus enums definem os dados; `TaskStorage` encapsula SharedPreferences; `TaskController` concentra estado, filtros e operações; widgets e páginas apresentam e recebem as ações. A estrutura mantém responsabilidades separadas sem camadas artificiais.

## Estrutura

```text
lib/
  app/app.dart
  features/
    dashboard/pages/dashboard_page.dart
    tasks/
      controllers/task_controller.dart
      models/task.dart
      repositories/task_storage.dart
      widgets/task_card.dart
      widgets/task_form_dialog.dart
      widgets/task_list_view.dart
  main.dart
```

## Como executar

```bash
flutter pub get
flutter run
```

Para executar no Flutter Web:

```bash
flutter run -d chrome
```

## Testes

```bash
flutter test
```

## Qualidade

```bash
flutter analyze
flutter build web
```

## Screenshots

Espaço reservado para capturas de tela da aplicação. Nenhuma imagem foi incluída neste MVP.

## Roadmap

Possíveis evoluções incluem backend, autenticação, sincronização, colaboração e persistência remota. Esses itens não fazem parte do MVP atual.
