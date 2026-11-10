import 'package:economycraft/services/modules/supabase_admin.dart';
import 'package:economycraft/services/modules/supabase_company.dart';
import 'package:economycraft/services/modules/supabase_home.dart';
import 'package:economycraft/services/modules/supabase_loan.dart';
import 'package:economycraft/services/modules/supabase_order.dart';
import 'package:economycraft/services/modules/supabase_product.dart';
import 'package:economycraft/services/modules/supabase_share.dart';
import 'package:economycraft/services/modules/supabase_storage.dart';
import 'package:economycraft/services/modules/supabase_player.dart';
import 'package:economycraft/services/modules/supabase_versioning.dart';
import 'package:economycraft/services/modules/supabase_wallet.dart';

class SupabaseHelper {
  static final storage = SupabaseStorage();
  static final company = SupabaseCompany();
  static final order = SupabaseOrder();
  static final product = SupabaseProduct();
  static final share = SupabaseShare();
  static final player = SupabasePlayer();
  static final versioning = SupabaseVersioning();
  static final wallet = SupabaseWallet();
  static final admin = SupabaseAdmin();
  static final home = SupabaseHome();
  static final loan = SupabaseLoan();
}
