// Importa o pacote "material", que é a biblioteca visual do Google. 
// Ela contém todos os botões, cores, textos e formatos padrões do Flutter.
import 'package:flutter/material.dart';

// O "main" é o ponto de partida do aplicativo (assim como no C, Java ou Python).
// É a primeira coisa que o celular roda quando você abre o app.
void main() {
  // runApp é a função que pega o seu app e o "injeta" na tela do celular.
  runApp(const MyApp());
}

// "MyApp" é a base do aplicativo. Ele é um StatelessWidget (widget sem estado), 
// porque as configurações gerais do app (tema, título) não mudam enquanto você usa.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp é o "envelope" de todo app Flutter. 
    // Ele gerencia a navegação entre telas, idioma e o tema visual geral.
    return MaterialApp(
      title: 'Lista de Tarefas', // Título interno (usado no gerenciador de tarefas do celular)
      debugShowCheckedModeBanner: false, // Tira a faixa vermelha feia de "DEBUG" do canto da tela
      theme: ThemeData(
        // Define a cor principal do app. O Flutter gera automaticamente 
        // os tons claros e escuros a partir dessa cor "semente" (deepPurple).
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Usa o design mais moderno e atualizado do Google
      ),
      // "home" define qual é a primeira tela que vai aparecer quando o app abrir.
      home: const TodoPage(),
    );
  }
}

// ---------------- MODELO DE DADOS ---------------- //

// Criamos uma classe simples (como um Dicionário ou Objeto) para representar UMA tarefa.
class Tarefa {
  String titulo; // O texto da tarefa (ex: "Comprar pão")
  bool concluida; // O estado da tarefa (verdadeiro/falso para o checkbox)

  // Construtor: o "required" obriga que você passe um título ao criar a tarefa.
  // Já o "concluida = false" diz que, por padrão, toda tarefa nasce desmarcada.
  Tarefa({required this.titulo, this.concluida = false});
}

// ---------------- TELA PRINCIPAL (STATEFUL) ---------------- //

// "TodoPage" é um StatefulWidget (widget com estado). 
// Usamos ele porque a tela VAI MUDAR constantemente (adicionar, remover, riscar tarefas).
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

// Esta classe oculta (começa com "_") é quem realmente guarda os dados e desenha a TodoPage.
class _TodoPageState extends State<TodoPage> {
  
  // 1. O Controlador de Texto: Ele "escuta" e pega tudo o que o usuário digita no campo de texto.
  final TextEditingController _taskController = TextEditingController();

  // 2. Nossa "Base de Dados" local: Uma lista vazia que vai guardar objetos do tipo "Tarefa".
  final List<Tarefa> _tarefas = [];

  // -------- FUNÇÕES DO CRUD (LÓGICA) -------- //

  // Função para CRIAR (Adicionar) uma tarefa nova
  void _adicionarTarefa() {
    // Verifica se o texto digitado não está vazio (ignora espaços em branco usando o trim)
    if (_taskController.text.trim().isNotEmpty) {
      
      // setState é o coração do Flutter dinâmico!
      // Ele avisa o Flutter: "Ei, os dados mudaram! Desenhe a tela de novo!"
      setState(() {
        // Adiciona uma nova Tarefa na nossa lista pegando o texto que foi digitado
        _tarefas.add(Tarefa(titulo: _taskController.text.trim()));
        
        // Limpa o campo de texto para o usuário poder digitar a próxima tarefa
        _taskController.clear(); 
      });
      
      // Após adicionar, esta linha manda o teclado do celular se esconder automaticamente
      FocusScope.of(context).unfocus();
    }
  }

  // Função para ATUALIZAR (Marcar/Desmarcar a tarefa do checkbox)
  void _alternarTarefa(int index) {
    setState(() {
      // Pega a tarefa na posição "index" e inverte o estado dela.
      // Se era true vira false. Se era false vira true.
      _tarefas[index].concluida = !_tarefas[index].concluida;
    });
  }

  // Função para DELETAR (Excluir uma tarefa na lixeira)
  void _removerTarefa(int index) {
    setState(() {
      // Remove o item da lista exatamente na posição "index" que foi clicada
      _tarefas.removeAt(index);
    });
  }

  // -------- DESENHO DA TELA (INTERFACE) -------- //

  @override
  Widget build(BuildContext context) {
    // Scaffold é o "esqueleto" padrão de uma tela (barra no topo, corpo, botões flutuantes)
    return Scaffold(
      
      // O AppBar é a barra superior do aplicativo
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        centerTitle: true, // Centraliza o texto
        // Pega a cor principal que definimos lá no início (o deepPurple)
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      
      // O Padding desgruda os elementos das bordas da tela (dá um respiro de 16 pixels)
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        
        // Column empilha os elementos de cima para baixo (verticalmente)
        child: Column(
          children: [
            
            // 1. ÁREA SUPERIOR (Campo de Texto e Botão de +)
            // Row coloca os elementos um do lado do outro (horizontalmente)
            Row(
              children: [
                
                // Expanded é crucial aqui: ele diz pro TextField "Cresça e ocupe todo 
                // o espaço livre da linha, mas não esmague o botão de adicionar".
                Expanded(
                  child: TextField(
                    controller: _taskController, // Conecta o campo ao nosso controlador
                    decoration: const InputDecoration(
                      labelText: 'Nova tarefa', // O texto que fica como dica
                      border: OutlineInputBorder(), // Coloca aquela bordinha quadrada bonita
                    ),
                    // Se o usuário apertar o botão "Enter" no teclado do celular, chama a função de adicionar
                    onSubmitted: (_) => _adicionarTarefa(),
                  ),
                ),
                
                // Dá um espacinho vazio de 16 pixels entre o campo de texto e o botão
                const SizedBox(width: 16),
                
                // O botão redondo de adicionar (+)
                FloatingActionButton(
                  onPressed: _adicionarTarefa, // O que fazer ao clicar
                  child: const Icon(Icons.add), // O ícone de "+"
                ),
              ],
            ),
            
            // Espaço vazio entre a área de adicionar e a lista
            const SizedBox(height: 24),

            // 2. ÁREA INFERIOR (A Lista de Tarefas)
            // Expanded aqui diz pra lista: "Ocupe todo o espaço que sobrou até o fim da tela".
            // Sem o Expanded aqui, o Flutter daria um erro de tela infinita (Overflow).
            Expanded(
              // "Operador Ternário": Se a lista estiver vazia (?), mostre uma mensagem amigável.
              // Se não estiver vazia (:), mostre a lista de tarefas.
              child: _tarefas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma tarefa ainda. Adicione uma!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  // ListView.builder é a melhor forma de fazer listas no Flutter!
                  // Ele tem "Lazy Loading", ou seja, só gasta memória pra desenhar na tela 
                  // as tarefas que o usuário está realmente enxergando no momento.
                  : ListView.builder(
                      itemCount: _tarefas.length, // Avisa ao builder quantas tarefas existem no total
                      
                      // O itemBuilder roda uma vez para cada tarefa existente
                      itemBuilder: (context, index) {
                        // Pega a tarefa específica da rodada atual
                        final tarefa = _tarefas[index];
                        
                        // Card é um widget de "cartão", dá aquele fundo branco com sombrinha leve
                        return Card(
                          elevation: 2, // Altura da sombra
                          margin: const EdgeInsets.symmetric(vertical: 6), // Espaço entre os cartões
                          
                          // ListTile é um widget perfeitamente desenhado para linhas de listas.
                          // Ele já tem espaços certinhos para ícones na esquerda (leading) e direita (trailing).
                          child: ListTile(
                            
                            // Checkbox (Fica na esquerda da linha)
                            leading: Checkbox(
                              value: tarefa.concluida, // Lê do banco de dados se tá true ou false
                              onChanged: (bool? value) {
                                // Se o usuário clicar no checkbox, chama a função de alterar
                                _alternarTarefa(index);
                              },
                            ),
                            
                            // O Texto principal da tarefa
                            title: Text(
                              tarefa.titulo,
                              // Lógica de estilo dinâmico:
                              style: TextStyle(
                                // Se estiver concluída, risca o texto. Se não, deixa normal.
                                decoration: tarefa.concluida
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                // Se estiver concluída, deixa cinza. Se não, deixa preto.
                                color: tarefa.concluida ? Colors.grey : Colors.black,
                              ),
                            ),
                            
                            // Botão de Deletar (Fica na direita da linha)
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              // Se o usuário clicar, chama a função passando a posição (index) a ser apagada
                              onPressed: () => _removerTarefa(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
