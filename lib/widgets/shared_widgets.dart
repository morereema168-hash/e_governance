import 'package:flutter/material.dart';
import '../theme.dart';

class AppAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color color;
  const AppAvatar({super.key, required this.initials, this.size = 36, this.color = AppColors.orange});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.73)]),
        boxShadow: [BoxShadow(color: color.withOpacity(0.33), blurRadius: 10, offset: const Offset(0,3))]),
      child: Center(child: Text(initials,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: size*0.36, fontFamily:'Nunito'))),
    );
  }
}

class AppChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? bgColor;
  final bool active;
  final VoidCallback? onTap;
  final bool small;
  const AppChip({super.key, required this.label, required this.color,
    this.bgColor, this.active=false, this.onTap, this.small=false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: small?10:13, vertical: small?3:5),
        decoration: BoxDecoration(
          color: active ? color : (bgColor ?? color.withOpacity(0.12)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3))),
        child: Text(label, style: TextStyle(color: active?Colors.white:color,
          fontWeight: FontWeight.w700, fontSize: small?11:12, fontFamily:'Nunito')),
      ));
  }
}

class AppBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool outline;
  final VoidCallback? onTap;
  final bool small;
  final bool disabled;
  final bool full;
  final IconData? icon;
  const AppBtn({super.key, required this.label, this.color=AppColors.orange,
    this.outline=false, this.onTap, this.small=false,
    this.disabled=false, this.full=false, this.icon});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: full?double.infinity:null,
      child: Material(
        color: disabled?AppColors.grey.withOpacity(0.3):(outline?Colors.transparent:color),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(onTap: disabled?null:onTap, borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: small?16:22, vertical: small?8:13),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
              border: Border.all(color: disabled?AppColors.grey:color, width: 2),
              boxShadow: outline||disabled?null:[BoxShadow(color:color.withOpacity(0.25),blurRadius:14,offset:const Offset(0,4))]),
            child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon!=null)...[Icon(icon,size:18,color:outline?color:Colors.white),const SizedBox(width:6)],
                Text(label, style: TextStyle(color:disabled?AppColors.grey:(outline?color:Colors.white),
                  fontWeight:FontWeight.w800, fontSize:small?13:14, fontFamily:'Nunito')),
              ]),
          ))));
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? bgColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;
  const AppCard({super.key, required this.child, this.padding,
    this.onTap, this.borderColor, this.bgColor, this.borderWidth, this.borderRadius});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Container(margin: const EdgeInsets.only(bottom:12),
        decoration: BoxDecoration(
          color: bgColor??AppColors.white,
          borderRadius: borderRadius??BorderRadius.circular(20),
          border: Border.all(color: borderColor??AppColors.border, width: borderWidth??1),
          boxShadow: [BoxShadow(color:Colors.black.withOpacity(0.05),blurRadius:14,offset:const Offset(0,2))]),
        child: ClipRRect(borderRadius: borderRadius??BorderRadius.circular(20),
          child: Padding(padding: padding??const EdgeInsets.all(16), child: child))));
  }
}

class AnimatedBar extends StatefulWidget {
  final double value;
  final Color color;
  final double height;
  const AnimatedBar({super.key, required this.value, this.color=AppColors.orange, this.height=8});
  @override State<AnimatedBar> createState() => _AnimatedBarState();
}
class _AnimatedBarState extends State<AnimatedBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync:this, duration:const Duration(milliseconds:900));
    _anim = Tween<double>(begin:0, end:widget.value/100)
        .animate(CurvedAnimation(parent:_ctrl, curve:Curves.easeInOut));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return AnimatedBuilder(animation:_anim,
      builder:(_,__)=>ClipRRect(borderRadius:BorderRadius.circular(99),
        child: LinearProgressIndicator(value:_anim.value, minHeight:widget.height,
          backgroundColor:widget.color.withOpacity(0.15),
          valueColor:AlwaysStoppedAnimation(widget.color))));
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});
  @override Widget build(BuildContext context) {
    Color c;
    switch(status) {
      case 'Completed': case 'Resolved': c=AppColors.green; break;
      case 'In Progress': c=AppColors.blue; break;
      case 'Pending': c=AppColors.gold; break;
      default: c=AppColors.grey;
    }
    return AppChip(label:status, color:c, bgColor:c.withOpacity(0.12), small:true);
  }
}

class PageHeader extends StatelessWidget {
  final String tag;
  final String title;
  final String? sub;
  final Widget? bottom;
  const PageHeader({super.key, required this.tag, required this.title, this.sub, this.bottom});
  @override Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18,20,18,24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[AppColors.navy, AppColors.navyLight])),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Text(tag, style:const TextStyle(fontSize:10, color:Color(0xFFFB923C), fontWeight:FontWeight.w800, letterSpacing:1)),
        const SizedBox(height:4),
        Text(title, style:const TextStyle(fontSize:22, fontWeight:FontWeight.w900, color:Colors.white)),
        if(sub!=null)...[const SizedBox(height:4), Text(sub!, style:const TextStyle(fontSize:12, color:Colors.white70))],
        if(bottom!=null)...[const SizedBox(height:14), bottom!],
      ]));
  }
}

class MapWidget extends StatelessWidget {
  final String label;
  final double height;
  const MapWidget({super.key, required this.label, this.height=160});
  @override Widget build(BuildContext context) {
    return ClipRRect(borderRadius:BorderRadius.circular(16),
      child: Container(height:height,
        decoration:const BoxDecoration(gradient:LinearGradient(
          begin:Alignment.topLeft, end:Alignment.bottomRight,
          colors:[Color(0xFFd4ebba), Color(0xFF90bc6e)])),
        child: Stack(children:[
          Positioned(top:height/2-1.5, left:0, right:0, child:Container(height:3, color:Colors.white38)),
          Positioned(left:120, top:0, bottom:0, child:Container(width:3, color:Colors.white38)),
          Positioned(top:height*0.22, left:80, child:Column(children:[
            Transform.rotate(angle:-0.785,
              child:Container(width:16,height:16,decoration:BoxDecoration(color:AppColors.orange,
                borderRadius:BorderRadius.circular(3),
                border:Border.all(color:Colors.white,width:2),
                boxShadow:[BoxShadow(color:Colors.black26,blurRadius:5)]))),
            const SizedBox(height:2),
            Container(padding:const EdgeInsets.symmetric(horizontal:5,vertical:2),
              decoration:BoxDecoration(color:Colors.white.withOpacity(0.92),borderRadius:BorderRadius.circular(4)),
              child:const Text('Work Site',style:TextStyle(fontSize:9,fontWeight:FontWeight.w800))),
          ])),
          Positioned(bottom:8,left:10,child:Container(
            padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
            decoration:BoxDecoration(color:Colors.white.withOpacity(0.92),borderRadius:BorderRadius.circular(8)),
            child:Text('📍 $label',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w700)))),
        ])));
  }
}
