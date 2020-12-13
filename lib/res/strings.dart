import 'package:anime/auxiliar/import.dart';
import 'theme.dart';

class AppResources {
  static const String APP_NAME = 'Anime';
  static const String company_name = 'OkiSoftware';
  static const String app_email = 'ookiisoftware@gmail.com';
  static const String pix = 'e92ebe7c-b87a-4865-ad75-46ab1713e96f';
  static const String playStoryLink = 'https://play.google.com/store/apps/details?id=com.ookiisoftware.anime';

  static const String CRUNCHYROLL_PACKAGE = 'com.crunchyroll.crunchyroid';
}

class Strings {
  static const String CRUNCHYROLL = 'CRUNCHYROLL';
  static const String CANCELAR = 'Cancelar';
  static const String OK = 'OK';
  static const String SIM = 'Sim';
  static const String POR = 'Por';
  static const String NAO = 'Não';
  static const String LINK = 'LINK';
  static const String VERSAO = 'Versão';
  static const String CONTATOS = 'Contatos';
  static const String AVANCADO = 'Avançado';
  static const String SIMPLES = 'Simples';
  static const String PESQUISAR = 'Pesquisar';
  static const String SUGESTAO = 'Sugestão';
  static const String LOGOUT = 'Logout';

  static const String ANIMACAO = 'Animação';
  static const String HIRTORIA = 'História';
  static const String TRACO = 'Traço';
  static const String FIM = 'Final';
  static const String ECCHI = 'Ecchi';
  static const String COMEDIA = 'Comédia';
  static const String ROMANCE = 'Romance';
  static const String AVENTURA = 'Aventura';
  static const String DRAMA = 'Drama';
  static const String TERROR = 'Terror';
  static const String ACAO = 'Ação';
  static const String EDITAR = 'Editar';
  static const String EXCLUIR = 'Excluir';
  static const String MOVER = 'Mover';

  static const String ASSISTINDO = 'Assistindo';
  static const String FAVORITOS = 'Favoritos';
  static const String CONCLUIDOS = 'Concluidos';

  static const String TITULO = 'Titulo';
  static const String NOME = 'Nome';
  static const String SINOPSE = 'Sinopse';
  static const String OBSERVACAO = 'Observação';
  static const String GENEROS = 'Gêneros';
  static const String MEDIA = 'Média';
  static const String VOTOS = 'Votos';
  static const String TIPO = 'Tipo';
}

class Titles {
  static const String MAIN = 'Animes';
  static const String ANIME = 'Anime';
  static const String ONLINE = 'ONLINE';
  static const String DESEJOS = 'ASSISTINDO';
  static const String FAVORITOS = 'FAVORITOS';
  static const String CONCLUIDOS = 'CONCLUIDOS';
  static const String ADD_ANIME = 'Adicionar Anime';
  static const String ADMIN = 'Admin';
  static const String CONFIGURACOES = 'CONFIGURAÇÕES';
  static const String INFORMACOES = 'INFORMAÇÕES';
  static const String GENEROS = 'GÊNEROS';

  static const String MOVER_ITEM = 'Para onde deseja mover?';
  static const String ADD_ITEM = 'Onde deseja adicionar?';
  static const String ALTERAR_FILTRO = 'Filtrar lista';

  static const String AVISO_ITEM_REPETIDO = 'Este item já está em sua lista de ';

  static const main_page = [DESEJOS, FAVORITOS, CONCLUIDOS, ONLINE, ADMIN];
}

class MyTexts {
  static const String DADOS_SALVOS = 'Dados Salvos';
  static const String FAZER_LOGIN = 'Fazer Login';
  static const String LIMPAR_TUDO = 'Limpar Tudo';
  static const String DIGITE_AQUI = 'Digite aqui';
  static const String ENVIE_SUGESTAO = 'Enviar Sugestão | Critica';
  static const String ANINE_SUGESTAO = 'Sugerir anime';
  static const String ENVIAR_SUGESTAO_TITLE = 'Qual a sua sugestão ou critica?';
  static const String REPORTAR_PROBLEMA = 'Reportar problema';
  static const String REPORTAR_PROBLEMA_TITLE = 'Qual o problema deste anime?';
  static const String REPORTAR_PROBLEMA_AGRADECIMENTO = 'Obrigado pelo seu feedback';
  static const String ENVIE_SUGESTAO_AGRADECIMENTO = 'Obrigado pela sua ${Strings.SUGESTAO}';

  static const String EXCLUIR_ITEM = 'Deseja excluir este item da lista de';
  static const String ULTIMO_VISTO = 'Ultimo assistido';

  static const String EDICAO_OBS_1 = 'Obs: -1 == Não se aplica';
  static const String EDICAO_OBS_2 = 'Obs: Defina os valores de acordo com a \'sua\' opnião';

  static const String ALTERAR_FILTRO = 'Veja exemplos de como usar os filtros clicando em \'Exemplos\'';
  static const String AVISO_ITEM_REPETIDO = 'Deseja sobrescreve-lo?';
}

class MyErros {
  static const String ABRIR_LINK = 'Erro ao abrir o link';
  static const String ABRIR_EMAIL = 'Erro ao enviar email';
  static const String ERRO_GENERICO = 'Ocorreu um erro';
}

class MenuMain {
  static const String config = 'Configurações';
  static const String sobre = 'Sobre';
  static const String logout = 'Logout';
}

class Arrays {
  static List<String> thema = [OkiThemeMode.sistema, OkiThemeMode.claro, OkiThemeMode.escuro];

  ///Ordem de listagem dos animes
  static List<String> ordem = [ListOrder.nome, ListOrder.dataAsc, ListOrder.dataDsc];
  static List<String> menuMain = [MenuMain.config, MenuMain.sobre, MenuMain.logout];
}