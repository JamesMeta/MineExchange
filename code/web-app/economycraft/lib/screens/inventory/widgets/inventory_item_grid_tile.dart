import 'package:cached_network_image/cached_network_image.dart';
import 'package:economycraft/classes/modals/inventory_item.dart';
import 'package:flutter/material.dart';

class InventoryItemGridTile extends StatelessWidget {
  final InventoryItem inventoryItem;
  final VoidCallback? onTap;

  const InventoryItemGridTile({
    super.key,
    required this.inventoryItem,
    this.onTap,
  });

  // ── Design Constants ────────────────────────────────────────────────────

  static const Color _accentTealLight = Color.fromARGB(255, 229, 255, 252);
  static const Color _textDark = Color.fromARGB(255, 50, 50, 50);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: _accentTealLight,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(20, 0, 0, 0),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAvatar(),
                const SizedBox(height: 8),
                _buildName(),
                const SizedBox(height: 2),
                _buildMinecraftTag(),
                const SizedBox(height: 6),
                _buildQuantityBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Avatar ────────────────────────────────────────────────────────────────

  Widget _buildAvatar() {
    return Expanded(
      child: CachedNetworkImage(
        imageUrl: inventoryItem.marketItem.avatarUrl,
        fit: BoxFit.contain,
        placeholder:
            (context, url) => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        errorWidget:
            (context, url, error) => const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: Colors.grey,
              ),
            ),
      ),
    );
  }

  // ── Name ──────────────────────────────────────────────────────────────────

  Widget _buildName() {
    return Text(
      inventoryItem.marketItem.name,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: _textDark,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ── Minecraft Tag ─────────────────────────────────────────────────────────

  Widget _buildMinecraftTag() {
    return Text(
      inventoryItem.marketItem.minecraftTag,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[500],
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ── Quantity Badge ────────────────────────────────────────────────────────

  Widget _buildQuantityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _accentTealLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'x${inventoryItem.quantity}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 0, 150, 136),
        ),
      ),
    );
  }
}
