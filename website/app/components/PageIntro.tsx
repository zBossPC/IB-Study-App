type Props = {
  kicker: string;
  title: string;
  lead: string;
};

export function PageIntro({ kicker, title, lead }: Props) {
  return (
    <section className="section wrap page-intro">
      <p className="section-kicker">{kicker}</p>
      <h1>{title}</h1>
      <p>{lead}</p>
    </section>
  );
}
