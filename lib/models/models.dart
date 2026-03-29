import 'package:flutter/material.dart';
import '../theme.dart';

class AppUser {
  final String email, role, name, avatar, ward;
  const AppUser({required this.email,required this.role,required this.name,required this.avatar,required this.ward});
}

const Map<String,AppUser> USERS = {
  'mayor@np.gov':   AppUser(email:'mayor@np.gov',  role:'mayor',      name:'Mayor Ramesh Patil',  avatar:'RP',ward:'All'),
  'sevak@np.gov':   AppUser(email:'sevak@np.gov',  role:'nagarsevak', name:'Sevak Sunita Jadhav', avatar:'SJ',ward:'Ward 3'),
  'water@dept.gov': AppUser(email:'water@dept.gov',role:'department', name:'Water Dept Officer',  avatar:'WD',ward:'All'),
  'amit@gmail.com': AppUser(email:'amit@gmail.com',role:'citizen',    name:'Amit Sharma',         avatar:'AS',ward:'Ward 3'),
};

class VoteProject {
  final String id,title,cat,desc;
  final int budget;
  final Color color;
  final IconData icon;
  const VoteProject({required this.id,required this.title,required this.budget,required this.color,required this.cat,required this.desc,required this.icon});
}

class VoteTier {
  final String id,label,sub,hint;
  final int maxPick;
  final Color color,bgColor;
  final List<VoteProject> projects;
  const VoteTier({required this.id,required this.label,required this.sub,required this.maxPick,required this.color,required this.bgColor,required this.hint,required this.projects});
}

final List<VoteTier> TIERS = [
  VoteTier(id:'mega',label:'Mega Projects',sub:'₹10 Cr+',maxPick:1,color:AppColors.rose,bgColor:AppColors.roseLight,
    hint:'Game-changing infrastructure — choose your single top priority.',
    projects:[
      VoteProject(id:'m1',title:'Underground Piped Water Network',budget:150000000,color:AppColors.teal,cat:'Water',icon:Icons.water_drop_outlined,desc:'24/7 pressurised pipelines across all 12 wards. 80,000 households.'),
      VoteProject(id:'m2',title:'4-Lane MG Road Expansion',budget:120000000,color:AppColors.orange,cat:'Roads',icon:Icons.add_road,desc:'Widen Rampur\'s busiest road with footpaths, cycling tracks & smart signals.'),
      VoteProject(id:'m3',title:'City Solar Micro-Grid',budget:110000000,color:AppColors.gold,cat:'Energy',icon:Icons.solar_power,desc:'100 kW solar for civic buildings, streetlights & pumping stations.'),
    ]),
  VoteTier(id:'major',label:'Major Projects',sub:'₹5–10 Cr',maxPick:2,color:AppColors.blue,bgColor:AppColors.blueLight,
    hint:'Significant civic upgrades — rank up to 2 projects.',
    projects:[
      VoteProject(id:'j1',title:'New Municipal Community Hall',budget:80000000,color:AppColors.blue,cat:'Civic',icon:Icons.account_balance,desc:'800-seat hall for meetings, skill training & cultural events.'),
      VoteProject(id:'j2',title:'Central Eco-Park & Jogging Track',budget:60000000,color:AppColors.green,cat:'Green Spaces',icon:Icons.park,desc:'5-acre eco-park with jogging track, open-air gym & playground.'),
      VoteProject(id:'j3',title:'Renovated Main Market Complex',budget:55000000,color:AppColors.rose,cat:'Commerce',icon:Icons.storefront,desc:'Covered walkways, uniform stalls, CCTV & fire safety upgrades.'),
    ]),
  VoteTier(id:'smart',label:'Smart Projects',sub:'Under ₹5 Cr',maxPick:3,color:AppColors.purple,bgColor:AppColors.purpleLight,
    hint:'High-impact improvements for Rampur — rank up to 3.',
    projects:[
      VoteProject(id:'s1',title:'Upgraded Public Library & E-Centre',budget:38000000,color:AppColors.navy,cat:'Education',icon:Icons.local_library,desc:'Digital reading pods, e-learning, free Wi-Fi & 3D printer lab.'),
      VoteProject(id:'s2',title:'Heritage Fountain & City Square',budget:45000000,color:AppColors.purple,cat:'Beautification',icon:Icons.water,desc:'Illuminated fountain, stone seating & landscaping at clock tower.'),
      VoteProject(id:'s3',title:'Smart Street Lighting – All Wards',budget:30000000,color:AppColors.gold,cat:'Electricity',icon:Icons.lightbulb_outline,desc:'2,400 auto-dimming LEDs across all wards. 60% energy saving.'),
    ]),
];

class Report {
  final String id,dept,title,desc,time,ticket,ward;
  String status;
  Report({required this.id,required this.dept,required this.title,required this.desc,required this.status,required this.time,required this.ticket,required this.ward});
}

class Post {
  final int id,comments;
  final String user,av,time,body;
  int likes; bool liked;
  Post({required this.id,required this.user,required this.av,required this.time,required this.body,required this.likes,required this.comments,required this.liked});
}

class Fundraiser {
  final int id,goal;
  final String type,title,desc;
  int raised,backers;
  Fundraiser({required this.id,required this.type,required this.title,required this.goal,required this.raised,required this.desc,required this.backers});
}

class Tender {
  final int id,value,pct;
  final String title,contractor,due,status,sector;
  final List<String> updates;
  const Tender({required this.id,required this.title,required this.contractor,required this.value,required this.due,required this.status,required this.pct,required this.sector,required this.updates});
}

const List<Tender> TENDERS = [
  Tender(id:1,title:'MG Road Tarring',contractor:'Mehta Constructions',value:12500000,due:'Jun 2025',status:'In Progress',pct:65,sector:'Roads',updates:['Dec 10: 50% tarring done','Nov 20: Machinery deployed']),
  Tender(id:2,title:'Main Road Drainage',contractor:'Patil Infra Pvt Ltd',value:8200000,due:'Mar 2025',status:'Completed',pct:100,sector:'Water',updates:['Dec 1: Work completed & verified','Nov 10: Pipe laying started']),
  Tender(id:3,title:'Water Pipeline – N.Zone',contractor:'Aqua Engineers Ltd',value:18000000,due:'Sep 2025',status:'In Progress',pct:30,sector:'Water',updates:['Dec 8: Excavation – 2 km done']),
  Tender(id:4,title:'LED Street Lights',contractor:'BrightCity Solutions',value:6500000,due:'Apr 2025',status:'Pending',pct:0,sector:'Electricity',updates:['Dec 5: Tender awarded. Work starts Jan 2025']),
];

String fmtCr(int n) {
  if(n>=10000000) return '₹${(n/10000000).toStringAsFixed(1)} Cr';
  if(n>=100000)   return '₹${(n/100000).toStringAsFixed(1)}L';
  return '₹${(n/1000).toStringAsFixed(0)}K';
}
Color statusColor(String s) { switch(s){case 'Completed':case 'Resolved':return AppColors.green;case 'In Progress':return AppColors.blue;case 'Pending':return AppColors.gold;default:return AppColors.grey;} }
int statusProgress(String s) { switch(s){case 'Resolved':case 'Completed':return 100;case 'In Progress':return 55;default:return 12;} }
